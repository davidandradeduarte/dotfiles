#!/usr/bin/env bash

set -e

if test ! $(which brew); then
    inf "Installing $(_g homebrew)"
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
else
    inf "Updating and upgrading $(_g homebrew)"
    brew update && brew upgrade
fi
eval "$(/opt/homebrew/bin/brew shellenv)"

formulae=(
    util-linux
    bash
    # bash-completion@2
    # bash-git-prompt
    # bash-snippets
    zsh
    # zsh-completions
    # zsh-syntax-highlighting
    # zsh-autosuggestions
    # zsh-history-substring-search
    # zsh-lovers
    # zsh-navigation-tools
    # zsh-vi-mode
    fish
    fisher
    nushell
    starship
    oh-my-posh
    # xonsh
    # elvish
    vim
    neovim
    nano
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
    # rust
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
    romkatv/powerlevel10k/powerlevel10k
    Azure/kubelogin/kubelogin
    pure
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
)

inf "Installing brew formulae $(_g ${formulae[@]})"
brew install ${formulae[@]}

casks=(
    # powershell
    visual-studio-code
    # rider
    # intellij-idea
    # iterm2
    # alacritty
    # kitty
    google-chrome
    firefox
    # brave-browser
    slack
    microsoft-teams
    zoom
    # discord
    # spotify
    dotnet-sdk
    docker
    openvpn-connect
    cloudflare-warp
    rectangle
    maccy
    meetingbar
    caffeine
    # bitwarden # the brew version can't be used for browser integration
    # balenaetcher
    # vmware-fusion
)
inf "Installing brew casks $(_g ${casks[@]})"
brew install --cask ${casks[@]}

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
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
fi

inf "Installing $(_g oh-my-bash)"
if [ -d $HOME/.oh-my-bash ]; then
    warn "$(_y oh-my-bash) already installed"
else
    bash -c "$(curl -fsSL https://raw.githubusercontent.com/ohmybash/oh-my-bash/master/tools/install.sh)" --unattended
fi

inf "Installing $(_g oh-my-fish)"
if [ -d $HOME/.local/share/omf ]; then
    warn "$(_y oh-my-fish) already installed"
else
    curl -L https://get.oh-my.fish | fish -c 'source - --noninteractive --yes'
fi

inf "Setting up $(_g vim)"
curl -fLo $HOME/.vim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
symlink $HOME/.vimrc $dir/.config/.vimrc
vim +'PlugInstall --sync' +qa

code_extensions=(
    teabyii.ayu
    usernamehw.errorlens
    # iocave.customize-ui # causing vscode to crash
    # iocave.monkey-patch # causing vscode to crash
    golang.go-nightly
    ms-dotnettools.csharp
    GitHub.copilot-nightly
    groogle.termin-all-or-nothing
    donjayamanne.githistory
    vscodevim.vim
    skyapps.fish-vscode
    redhat.vscode-yaml
    ms-vscode.makefile-tools
    hashicorp.terraform
    hashicorp.hcl
    DavidAnson.vscode-markdownlint
    alexkrechik.cucumberautocomplete
)
inf "Installing vscode extensions $(_g ${code_extensions[@]})"
for extension in ${code_extensions[@]}; do
    inf "Installing vscode extension $(_g $extension)"
    code --install-extension $extension
done

inf "Installing font $(_g FiraCode)"
curl -fLo $HOME/Library/Fonts/FiraCode.zip "https://github.com/ryanoasis/nerd-fonts/releases/download/v2.2.2/FiraCode.zip"
unzip -o $HOME/Library/Fonts/FiraCode.zip -d $HOME/Library/Fonts
rm $HOME/Library/Fonts/FiraCode.zip
inf "Installing font $(_g JetBrainsMono)"
curl -fLo $HOME/Library/Fonts/JetBrainsMono.zip "https://download.jetbrains.com/fonts/JetBrainsMono-2.242.zip"
unzip -o $HOME/Library/Fonts/JetBrainsMono.zip -d $HOME/Library/Fonts
rm $HOME/Library/Fonts/JetBrainsMono.zip
inf "Installing font $(_g Meslo Nerd Font patched for Powerlevel10k)"
wget -qO "$HOME/Library/Fonts/MesloLGS NF Regular.ttf" "https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Regular.ttf"
wget -qO "$HOME/Library/Fonts/MesloLGS NF Bold.ttf" "https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Bold.ttf"
wget -qO "$HOME/Library/Fonts/MesloLGS NF Italic.ttf" "https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Italic.ttf"
wget -qO "$HOME/Library/Fonts/MesloLGS NF Bold Italic.ttf" "https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Bold%20Italic.ttf"

inf "Creating symlinks"
symlink $HOME/.gitconfig $dir/.config/.gitconfig
symlink $HOME/.bashrc $dir/.config/.bashrc
symlink $HOME/.zshrc $dir/.config/.zshrc
symlink $HOME/.p10k.zsh $dir/.config/.p10k.zsh
symlink $HOME/.config/fish/config.fish $dir/.config/config.fish
symlink $HOME/.tmux.conf $dir/.config/.tmux.conf
symlink $HOME/.config/nushell/config.nu $dir/.config/config.nu
symlink $HOME/.config/nushell/env.nu $dir/.config/env.nu
symlink $HOME/.config/powershell/Microsoft.PowerShell_profile.ps1 $dir/.config/Microsoft.PowerShell_profile.ps1
symlink "$HOME/Library/Application Support/Code/User/settings.json" $dir/.config/settings.json
symlink "$HOME/Library/Application Support/Code/User/keybindings.json" $dir/.config/keybindings.json
