#!/usr/bin/env bash

set -e

if [[ $arch != "aarch64" ]]; then
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
    eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
    formulae=(
        k9s
        curlie
        stern
    )
    inf "Installing brew formulae $(_g ${formulae[@]})"
    brew install -f ${formulae[@]}
else
    warn "Skipping $(_y Homebrew) installation on $(_y $arch). Unsupported."
fi

inf "Updating and upgrading $(_g apt)"
sudo apt update && sudo apt upgrade -y && sudo apt autoremove -y

required_apt_packages=(
    wget
    git
    curl
    apt-utils
    build-essential
    ca-certificates
    apt-transport-https
    gnupg
    software-properties-common
    unzip
    pkg-config
    lsb-release
    passwd
    libssl-dev
    fontconfig
    python3-dev
    python3-pip
    python3-setuptools
)
inf "Installing apt required packages $(_g ${required_apt_packages[@]})"
sudo apt install -y --assume-yes ${required_apt_packages[@]}
sudo apt update && sudo apt autoremove -y

inf "Adding $(_g kubernetes) repository"
sudo curl -fsSLo /etc/apt/keyrings/kubernetes-archive-keyring.gpg https://packages.cloud.google.com/apt/doc/apt-key.gpg
echo "deb [signed-by=/etc/apt/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list

inf "Adding $(_g helm) repository"
curl https://baltocdn.com/helm/signing.asc | gpg --dearmor | sudo tee /usr/share/keyrings/helm.gpg >/dev/null
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/helm.gpg] https://baltocdn.com/helm/stable/debian/ all main" | sudo tee /etc/apt/sources.list.d/helm-stable-debian.list

inf "Adding $(_g microsoft) repositories"
wget -q "https://packages.microsoft.com/config/ubuntu/$(lsb_release -rs)/packages-microsoft-prod.deb"
sudo dpkg -i packages-microsoft-prod.deb
rm packages-microsoft-prod.deb
wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor >packages.microsoft.gpg
sudo install -D -o root -g root -m 644 packages.microsoft.gpg /etc/apt/keyrings/packages.microsoft.gpg
sudo sh -c 'echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" > /etc/apt/sources.list.d/vscode.list'
rm -f packages.microsoft.gpg

inf "Adding $(_g github) repository"
curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg &&
    sudo chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg &&
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list >/dev/null &&
    inf "Adding $(_g node) repository"
curl -fsSL https://deb.nodesource.com/setup_19.x | sudo -E bash -

inf "Adding $(_g docker) repository"
sudo mkdir -p /etc/apt/keyrings
sudo rm -f /etc/apt/keyrings/docker.gpg
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
echo \
    "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list >/dev/null

inf "Adding $(_g universe) repository"
sudo add-apt-repository -y universe

sudo apt update && sudo apt autoremove -y
apt_packages=(
    zsh
    neovim
    tmux
    htop
    bat # batcat bin
    exa
    fd-find # fdfind bin
    neofetch
    kubectl
    helm
    ripgrep
    jq
    gh
    code
    nodejs
    docker-ce
    docker-ce-cli
    containerd.io
    docker-compose-plugin
)
inf "Installing apt packages $(_g ${apt_packages[@]})"
sudo apt install -y --assume-yes ${apt_packages[@]}
sudo apt update && sudo apt autoremove -y

pip_packages=(
    pre-commit
    thefuck
    tldr
)
inf "Installing pip packages $(_g ${pip_packages[@]})"
pip3 install --user ${pip_packages[@]}

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

inf "Configuring $(_g docker)"
if [ -z "$(pidof systemd)" ]; then
    warn "$(_y docker) requires systemd to be installed"
else
    sudo systemctl enable docker.service
    sudo systemctl enable containerd.service
    sudo systemctl start docker.service
    sudo systemctl start containerd.service
fi

inf "Installing $(_g z)"
wget https://raw.githubusercontent.com/rupa/z/master/z.sh -O $HOME/z.sh

inf "Installing $(_g fzf)"
if [ -d "$HOME/.fzf" ]; then
    warn "$(_y fzf) already installed"
else
    git clone --depth 1 https://github.com/junegunn/fzf.git $HOME/.fzf
    yes | $HOME/.fzf/install
fi

inf "Installing $(_g sops)"
sops_version=$(curl -s "https://api.github.com/repos/mozilla/sops/releases/latest" | grep '"tag_name":' | sed -E 's/.*"v*([^"]+)".*/\1/')
sops_arch=$(if [[ $arch == "aarch64" ]]; then echo "arm64"; else echo "amd64"; fi)
sudo wget "https://github.com/mozilla/sops/releases/download/v${sops_version}/sops-v${sops_version}.linux.${sops_arch}" -O /usr/local/bin/sops
sudo chmod +x /usr/local/bin/sops

inf "Installing $(_g lazygit)"
LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | grep '"tag_name":' | sed -E 's/.*"v*([^"]+)".*/\1/')
curl -Lo lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz"
sudo tar xf lazygit.tar.gz -C /usr/local/bin lazygit
rm -f lazygit.tar.gz

inf "Installing $(_g kubectx) and $(_g kubens)"
if [ -d "/opt/kubectx" ]; then
    warn "$(_y kubectx) already installed"
else
    sudo git clone https://github.com/ahmetb/kubectx /opt/kubectx
    symlink /opt/kubectx/kubectx /usr/local/bin/kubectx
    symlink /opt/kubectx/kubens /usr/local/bin/kubens
fi

inf "Installing $(_g terraform)"
tf_version=$(curl -s "https://api.github.com/repos/hashicorp/terraform/releases/latest" | grep '"tag_name":' | sed -E 's/.*"v*([^"]+)".*/\1/')
tf_arch=$(if [[ $arch == "aarch64" ]]; then echo "arm64"; else echo "amd64"; fi)
curl -Lo terraform.zip "https://releases.hashicorp.com/terraform/${tf_version}/terraform_${tf_version}_linux_${tf_arch}.zip"
sudo unzip -o terraform.zip -d /usr/local/bin
rm -f terraform.zip

inf "Installing $(_g terragrunt)"
tg_arch=$(if [[ $arch == "aarch64" ]]; then echo "arm64"; else echo "amd64"; fi)
tg_version=$(curl -s "https://api.github.com/repos/gruntwork-io/terragrunt/releases/latest" | grep '"tag_name":' | sed -E 's/.*"v*([^"]+)".*/\1/')
curl -Lo terragrunt "https://github.com/gruntwork-io/terragrunt/releases/download/v${tg_version}/terragrunt_linux_${tg_arch}"
sudo chmod +x terragrunt
sudo mv terragrunt /usr/local/bin/

inf "Installing $(_g go)"
go_arch=$(if [[ $arch == "aarch64" ]]; then echo "arm64"; else echo "amd64"; fi)
go_version=$(curl -s curl "https://go.dev/VERSION?m=text")
gotar="$go_version.linux-$go_arch.tar.gz"
wget "https://go.dev/dl/$gotar" -O /tmp/$gotar
sudo rm -rf /usr/local/go && sudo tar -C /usr/local -xzf /tmp/$gotar
rm -f /tmp/$gotar

go_modules=(
    github.com/derailed/k9s@v0.26.2 # can't install latest because go.mod contains a replace directive
    github.com/mikefarah/yq/v4@latest
    github.com/rs/curlie@latest
    golang.org/x/tools/gopls@latest
    golang.org/x/tools/cmd/goimports@latest
    sigs.k8s.io/kustomize/kustomize/v4@latest
    github.com/stern/stern@latest
)
inf "Installing go modules $(_g ${go_modules[@]})"
for module in ${go_modules[@]}; do
    go_bin=$(echo $module | rev | cut -d '/' -f1 | rev | cut -d '@' -f1)
    if [ command -v $go_bin ] &>/dev/null; then
        warn "$(_y $go_bin) already installed"
        continue
    fi
    inf "Installing go module $(_g $module)"
    /usr/local/go/bin/go install $module
done

inf "Installing $(_g golangci-lint)"
golangci_version=$(curl -s "https://api.github.com/repos/golangci/golangci-lint/releases/latest" | grep '"tag_name":' | sed -E 's/.*"v*([^"]+)".*/\1/')
curl -sSfL https://raw.githubusercontent.com/golangci/golangci-lint/master/install.sh | sh -s -- -b $(/usr/local/go/bin/go env GOPATH)/bin v${golangci_version}

inf "Installing $(_g rust)"
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y

rust_crates=()
inf "Installing rust crates $(_g ${rust_crates[@]})"
for crate in ${rust_crates[@]}; do
    if [ command -v $crate ] &>/dev/null; then
        warn "$(_y $crate) already installed"
        continue
    fi
    inf "Installing rust crate $(_g $crate)"
    $HOME/.cargo/bin/cargo install $crate
done

inf "Installing $(_g dotnet)"
dotnet_version=$(curl -s "https://api.github.com/repos/dotnet/sdk/releases/latest" | grep '"tag_name":' | sed -E 's/.*"v*([^"]+)".*/\1/')
curl -sSL https://dot.net/v1/dotnet-install.sh | bash /dev/stdin --version $dotnet_version # latest
curl -sSL https://dot.net/v1/dotnet-install.sh | bash                                      # LTS

inf "Installing $(_g krew)"
(
    cd "$(mktemp -d)" &&
        krew_os="$(uname | tr '[:upper:]' '[:lower:]')" &&
        krew_arch="$(uname -m | sed -e 's/x86_64/amd64/' -e 's/\(arm\)\(64\)\?.*/\1\2/' -e 's/aarch64$/arm64/')" &&
        krew_file="krew-${krew_os}_${krew_arch}" &&
        curl -fsSLO "https://github.com/kubernetes-sigs/krew/releases/latest/download/${krew_file}.tar.gz" &&
        tar zxvf "${krew_file}.tar.gz" &&
        ./"${krew_file}" install krew # kubectl-krew bin
)

inf "Installing $(_g kubelogin)"
kubelg_version=$(curl -s "https://api.github.com/repos/Azure/kubelogin/releases/latest" | grep '"tag_name":' | sed -E 's/.*"v*([^"]+)".*/\1/')
kubelg_arch=$(if [[ $arch == "aarch64" ]]; then echo "arm64"; else echo "amd64"; fi)
wget "https://github.com/Azure/kubelogin/releases/download/v${kubelg_version}/kubelogin-linux-${kubelg_arch}.zip" -O /tmp/kubelogin.zip
unzip -o /tmp/kubelogin.zip -d /tmp
sudo mv /tmp/bin/linux_${kubelg_arch}/kubelogin /usr/local/bin/
rm -rf /tmp/bin /tmp/kubelogin.zip

inf "Installing $(_g flux)"
curl -s https://fluxcd.io/install.sh | sudo bash

inf "Installing $(_g azure-cli)"
curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash -s -- -y

inf "Installing $(_g nix)"
if [ -d $HOME/.nix-profile ]; then
    warn "$(_y nix) already installed"
else
    # sudo rm -f /etc/bashrc.backup-before-nix
    sudo rm -f /etc/zshrc.backup-before-nix
    sh <(curl -L https://nixos.org/nix/install) --daemon --yes
fi

inf "Configuring $(_g neovim)"
git clone https://github.com/AstroNvim/AstroNvim ~/.config/nvim
nvim --headless +PackerSync +qall

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

inf "Installing font $(_g JetBrainsMono)"
curl -fLo $HOME/.local/share/fonts/JetBrainsMono.zip --create-dirs "https://download.jetbrains.com/fonts/JetBrainsMono-2.242.zip"
unzip -o $HOME/.local/share/fonts/JetBrainsMono.zip -d $HOME/.local/share/fonts
rm -f $HOME/.local/share/fonts/JetBrainsMono.zip

fc-cache -f -v

inf "Creating symlinks"
symlink $dir/.config/.gitconfig $HOME/.gitconfig
symlink $dir/.config/.zshrc $HOME/.zshrc
symlink $dir/.config/.tmux.conf $HOME/.tmux.conf
symlink $dir/.config/.alacritty.yml $HOME/.alacritty.yml
symlink $dir/.config/vscode/settings.json $HOME/.config/Code/User/settings.json
symlink $dir/.config/vscode/keybindings.json $HOME/.config/Code/User/keybindings.json
symlink $dir/.config/.ideavimrc $HOME/.ideavimrc
symlink $dir/dotfiles-private/.env $HOME/.env.private
symlink $dir/dotfiles-work/.env $HOME/.env.work
symlink $dir/dotfiles-work/.gitconfig $HOME/.gitconfig.work
for file in $dir/dotfiles-work/.gitconfig.*; do
    symlink $file $HOME/$(basename $file)
done

cp -rf $dir/dotfiles-private/.bin $HOME/.bin
