#!/usr/bin/env bash

set -e

inf "Updating and upgrading $(_g apt)"
sudo apt update && sudo apt upgrade -y

if [[ $arch != "aarch64" ]]; then
    if test ! $(which brew); then
        inf "Installing $(_g homebrew)"
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    else
        inf "Updating and upgrading $(_g homebrew)"
        brew update && brew upgrade
    fi

    formulae=(
        k9s
    )

    inf "Installing brew formulae $(_g ${formulae[@]})"
    brew install -v ${formulae[@]}
else
    warn "Skipping $(_y Homebrew) installation on $(_y $arch). Unsupported."
fi

packages=(
    apt-utils
    build-essential
    bash
    zsh
    fish
    git
    curl
    wget
    vim
    neovim
    nano
    tmux
    htop
    # fzf # couldn't get keybindings to work
    bat # batcat bin
    exa
    fd-find # fdfind
    neofetch
)

inf "Installing apt packages $(_g ${packages[@]})"
sudo apt install -y --assume-yes ${packages[@]}

inf "Installing $(_g fzf)"
if [ -d "$HOME/.fzf" ]; then
    warn "$(_y fzf) already installed"
    return
fi
git clone --depth 1 https://github.com/junegunn/fzf.git $HOME/.fzf
yes | $HOME/.fzf/install

inf "Installing $(_g lazygit)"
LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | grep '"tag_name":' | sed -E 's/.*"v*([^"]+)".*/\1/')
curl -Lo lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz"
sudo tar xf lazygit.tar.gz -C /usr/local/bin lazygit
rm -f lazygit.tar.gz

inf "Installing $(_g go)"
if [[ $arch == "aarch64" ]]; then
    gotar="go1.19.4.linux-arm64.tar.gz"
else
    gotar="go1.19.4.linux-amd64.tar.gz"
fi
wget "https://go.dev/dl/$gotar" -O /tmp/$gotar
sudo rm -rf /usr/local/go && sudo tar -C /usr/local -xzf /tmp/$gotar
rm -f /tmp/$gotar

go_modules=(
    # github.com/derailed/k9s@latest # go.mod contains replace directive, can't install
    github.com/derailed/k9s@v0.26.2
)

inf "Installing go modules $(_g ${go_modules[@]})"
for module in ${go_modules[@]}; do
    bin_name=$(echo $module | rev | cut -d '/' -f1 | rev | cut -d '@' -f1)
    if [ command -v $bin_name ] &>/dev/null; then
        warn "$(_y $bin_name) already installed"
        continue
    fi
    inf "Installing $(_g $module)"
    /usr/local/go/bin/go install $module
done

inf "Installing $(_g rust)"
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y

inf "Creating symlinks"
symlink $HOME/.bashrc $dir/ubuntu/config/.bashrc
symlink $HOME/.zshrc $dir/ubuntu/config/.zshrc

if [ -z $(which $shell) ]; then
    err "Failed to set $(_r $shell) as default shell"
    exit 1
fi
inf "Setting $(_g $(which $shell)) as default shell"
sudo chsh -s $(which $shell) $(whoami)
