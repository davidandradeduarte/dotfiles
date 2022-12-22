#!/usr/bin/env bash

set -e

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

inf "Updating and upgrading $(_g apt)"
sudo apt update && sudo apt upgrade -y && sudo apt autoremove -y

packages=(
    wget
    apt-utils
    build-essential
    ca-certificates
    apt-transport-https
    gnupg
    software-properties-common
    unzip
)
inf "Installing required $(_g apt) packages"
sudo apt install -y --assume-yes ${packages[@]}
sudo apt update && sudo apt autoremove -y

inf "Adding $(_g kubernetes) repository"
sudo curl -fsSLo /etc/apt/keyrings/kubernetes-archive-keyring.gpg https://packages.cloud.google.com/apt/doc/apt-key.gpg
echo "deb [signed-by=/etc/apt/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list
inf "Adding $(_g helm) repository"
curl https://baltocdn.com/helm/signing.asc | gpg --dearmor | sudo tee /usr/share/keyrings/helm.gpg >/dev/null
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/helm.gpg] https://baltocdn.com/helm/stable/debian/ all main" | sudo tee /etc/apt/sources.list.d/helm-stable-debian.list
sudo apt update && sudo apt autoremove -y

packages=(
    apt-utils
    build-essential
    ca-certificates
    apt-transport-https
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
    fd-find # fdfind bin
    neofetch
    kubectl
    helm
    ripgrep
    jq

)
inf "Installing apt packages $(_g ${packages[@]})"
sudo apt install -y --assume-yes ${packages[@]}
sudo apt update && sudo apt autoremove -y

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

inf "Installing $(_g kubectx) and $(_g kubens)"
sudo git clone https://github.com/ahmetb/kubectx /opt/kubectx
sudo ln -s /opt/kubectx/kubectx /usr/local/bin/kubectx
sudo ln -s /opt/kubectx/kubens /usr/local/bin/kubens
# fish completions
mkdir -p ~/.config/fish/completions
ln -s /opt/kubectx/completion/kubectx.fish ~/.config/fish/completions/
ln -s /opt/kubectx/completion/kubens.fish ~/.config/fish/completions/

inf "Installing $(_g terraform)"
tfversion=$(curl -s "https://api.github.com/repos/hashicorp/terraform/releases/latest" | grep '"tag_name":' | sed -E 's/.*"v*([^"]+)".*/\1/')
tfarch=$(if [[ $arch == "aarch64" ]]; then echo "arm64"; else echo "amd64"; fi)
curl -Lo terraform.zip "https://releases.hashicorp.com/terraform/${tfversion}/terraform_${tfversion}_linux_${tfarch}.zip"
sudo unzip terraform.zip -d /usr/local/bin
rm -f terraform.zip

inf "Installing $(_g terragrunt)"
tgarch=$(if [[ $arch == "aarch64" ]]; then echo "arm64"; else echo "amd64"; fi)
tgversion=$(curl -s "https://api.github.com/repos/gruntwork-io/terragrunt/releases/latest" | grep '"tag_name":' | sed -E 's/.*"v*([^"]+)".*/\1/')
curl -Lo terragrunt "https://github.com/gruntwork-io/terragrunt/releases/download/v${tgversion}/terragrunt_linux_${tgarch}"
sudo chmod +x terragrunt
sudo mv terragrunt /usr/local/bin/

inf "Installing $(_g go)"
goarch=$(if [[ $arch == "aarch64" ]]; then echo "arm64"; else echo "amd64"; fi)
goversion=$(curl -s curl "https://go.dev/VERSION?m=text")
gotar="$goversion.linux-$goarch.tar.gz"
wget "https://go.dev/dl/$gotar" -O /tmp/$gotar
sudo rm -rf /usr/local/go && sudo tar -C /usr/local -xzf /tmp/$gotar
rm -f /tmp/$gotar

go_modules=(
    # github.com/derailed/k9s@latest # go.mod contains replace directive, can't install
    github.com/derailed/k9s@v0.26.2
    github.com/mikefarah/yq/v4@latest
    golang.org/x/tools/gopls@latest
    golang.org/x/tools/cmd/goimports@latest
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

inf "Installing $(_g krew)"
(
    cd "$(mktemp -d)" &&
        krewos="$(uname | tr '[:upper:]' '[:lower:]')" &&
        krewarch="$(uname -m | sed -e 's/x86_64/amd64/' -e 's/\(arm\)\(64\)\?.*/\1\2/' -e 's/aarch64$/arm64/')" &&
        krewfile="krew-${krewos}_${krewarch}" &&
        curl -fsSLO "https://github.com/kubernetes-sigs/krew/releases/latest/download/${krewfile}.tar.gz" &&
        tar zxvf "${krewfile}.tar.gz" &&
        ./"${krewfile}" install krew # kubectl-krew bin
)

inf "Installing $(_g azure-cli)"
curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash -s -- -y

inf "Setting up $(_g vim)"
curl -fLo $HOME/.vim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
symlink $HOME/.vimrc $dir/ubuntu/config/.vimrc
vim +'PlugInstall --sync' +qa

inf "Creating symlinks"
symlink $HOME/.gitconfig $dir/ubuntu/config/.gitconfig
symlink $HOME/.bashrc $dir/ubuntu/config/.bashrc
symlink $HOME/.zshrc $dir/ubuntu/config/.zshrc
symlink $HOME/.config/fish/config.fish $dir/ubuntu/config/config.fish
symlink $HOME/.tmux.conf $dir/ubuntu/config/.tmux.conf
