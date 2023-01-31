#!/usr/bin/env bash

set -e

if test ! $(which brew); then
    inf "Installing $(_g homebrew)"
    if [ "$yes" = 1 ]; then
        NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    else
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    fi
else
    inf "Updating and upgrading $(_g homebrew)"
    brew update && brew upgrade
fi
eval "$(/opt/homebrew/bin/brew shellenv)"

formulae=(
    util-linux
    zsh
    neovim
    git
    curl
    wget
    tmux
    fzf
    bat
    exa
    fd
    go
    rustup-init
    neofetch
    k9s
    lazygit
    kubernetes-cli
    kubectx
    helm
    terraform
    terragrunt
    azure-cli
    ripgrep
    htop
    jq
    yq
    Azure/kubelogin/kubelogin
    adr-tools
    curlie
    gh
    golangci-lint
    kustomize
    pre-commit
    z
    thefuck
    sops
    stern
    tldr
    node
    watch
    fluxcd/tap/flux
    kyoh86/tap/richgo
    koekeishiya/formulae/yabai
    koekeishiya/formulae/skhd
    cmacrae/formulae/spacebar
    openvpn
    warp-cli
    colima
    docker
)

inf "Installing brew formulae $(_g ${formulae[@]})"
brew install -f ${formulae[@]}

casks=(
    karabiner-elements
    visual-studio-code
    intellij-idea
    alacritty
    firefox
    zoom # only comms i can't use on the browser
    dotnet-sdk
    maccy
    meetingbar
    # bitwarden # TODO: the brew version can't be used for browser integration, install from mas?
    homebrew/cask-fonts/font-fontawesome
    homebrew/cask-fonts/font-jetbrains-mono
)
inf "Installing brew casks $(_g ${casks[@]})"
brew install -f --cask ${casks[@]}

inf "Configuring $(_g yabai))"
warn "yabai needs SIP disabled to work properly. Please follow the instructions at $(_y 'https://github.com/koekeishiya/yabai/wiki/Disabling-System-Integrity-Protection')"
sudo sh -c 'echo "$(whoami) ALL=(root) NOPASSWD:sha256:$(shasum -a 256 $(which yabai) | cut -d '\'' '\'' -f1) $(which yabai) --load-sa" >> /private/etc/sudoers.d/yabai'

brew_services=(
    yabai
    skhd
    spacebar
)
inf "Starting brew services $(_g ${brew_services[@]})"
for service in ${brew_services[@]}; do
    brew services start $service
done

go_modules=(
    golang.org/x/tools/gopls@latest
    golang.org/x/tools/cmd/goimports@latest
)
inf "Installing go modules $(_g ${go_modules[@]})"
for module in ${go_modules[@]}; do
    go_bin=$(echo $module | rev | cut -d '/' -f1 | rev | cut -d '@' -f1)
    if [ command -v $go_bin ] &>/dev/null; then
        warn "$(_y $go_bin) already installed"
        continue
    fi
    inf "Installing go module $(_g $module)"
    /opt/homebrew/bin/go install $module
done

inf "Installing $(_g oh-my-zsh)"
if [ -d $HOME/.oh-my-zsh ]; then
    warn "$(_y oh-my-zsh) already installed"
else
    if [ "$yes" = 1 ]; then
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    else
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
    fi
fi

# inf "Installing $(_g oh-my-bash)"
# if [ -d $HOME/.oh-my-bash ]; then
#     warn "$(_y oh-my-bash) already installed"
# else
#     if [ "$yes" = 1 ]; then
#         bash -c "$(curl -fsSL https://raw.githubusercontent.com/ohmybash/oh-my-bash/master/tools/install.sh)" --unattended
#     else
#         bash -c "$(curl -fsSL https://raw.githubusercontent.com/ohmybash/oh-my-bash/master/tools/install.sh)"
#     fi
# fi

# inf "Installing $(_g oh-my-fish)"
# if [ -d $HOME/.local/share/omf ]; then
#     warn "$(_y oh-my-fish) already installed"
# else
#     curl -L https://get.oh-my.fish | fish -c 'source - --noninteractive --yes'
# fi

inf "Installing $(_g nix)"
if [ -d $HOME/.nix-profile ]; then
    warn "$(_y nix) already installed"
else
    # sudo rm -f /etc/bashrc.backup-before-nix
    sudo rm -f /etc/zshrc.backup-before-nix
    sh <(curl -L https://nixos.org/nix/install) --yes
fi

inf "Configuring $(_g neovim)"
git clone https://github.com/AstroNvim/AstroNvim ~/.config/nvim
/opt/homebrew/bin/nvim --headless +PackerSync +qall

code_extensions=()
while IFS= read -r line; do
    if [[ $line == \#* ]]; then
        continue
    fi
    code_extensions+=("$line")
done <$dir/.config/vscode/extensions.txt
inf "Installing vscode extensions $(_g ${code_extensions[@]})"
for extension in ${code_extensions[@]}; do
    inf "Installing vscode extension $(_g $extension)"
    code --install-extension $extension
done
code --disable-extension vscodevim.vim

inf "Creating symlinks"
symlink $dir/.config/.gitconfig $HOME/.gitconfig
symlink $dir/.config/.zshrc $HOME/.zshrc
symlink $dir/.config/.tmux.conf $HOME/.tmux.conf
symlink $dir/.config/.alacritty.yml $HOME/.alacritty.yml
symlink $dir/.config/vscode/settings.json "$HOME/Library/Application Support/Code/User/settings.json"
symlink $dir/.config/vscode/keybindings.json "$HOME/Library/Application Support/Code/User/keybindings.json"
symlink $dir/.config/.yabairc $HOME/.yabairc
symlink $dir/.config/.skhdrc $HOME/.skhdrc
symlink $dir/.config/spacebarrc $HOME/.config/spacebar/spacebarrc
symlink $dir/.config/karabiner.json $HOME/.config/karabiner/karabiner.json
symlink $dir/dotfiles-private/.env $HOME/.env.private
symlink $dir/dotfiles-work/.env $HOME/.env.work
symlink $dir/dotfiles-work/.gitconfig $HOME/.gitconfig.work
for file in $dir/dotfiles-work/.gitconfig.*; do
    symlink $file $HOME/$(basename $file)
done
