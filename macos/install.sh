#!/usr/bin/env bash

set -e

if test ! $(which brew); then
    inf "Installing $(_g homebrew)"
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
else
    inf "Updating and upgrading $(_g homebrew)"
    brew update && brew upgrade
fi

formulae=(
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
    # nushell
    # starship
    # oh-my-posh
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
)

inf "Installing brew formulae $(_g ${formulae[@]})"
brew install -v ${formulae[@]}

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
    # balenaetcher
    caffeine
    # bitwarden # the brew version can't be used for browser integration
)

inf "Installing brew casks $(_g ${casks[@]})"
brew install -v --cask ${casks[@]}

if [ -z $(which $shell) ]; then
    err "Failed to set $(_r $shell) as default shell"
    exit 1
fi
inf "Setting $(_g $(which $shell)) as default shell"
sudo chsh -s $(which $shell) $(whoami)
