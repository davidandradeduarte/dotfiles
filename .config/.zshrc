# Set up the prompt

autoload -Uz promptinit
promptinit
# prompt adam1
# prompt pure

setopt histignorealldups sharehistory

# Use emacs keybindings even if our EDITOR is set to vi
bindkey -e

# Keep 1000 lines of history within the shell and save it to ~/.zsh_history:
HISTSIZE=1000
SAVEHIST=1000
HISTFILE=~/.zsh_history

# Use modern completion system
autoload -Uz compinit
compinit

zstyle ':completion:*' auto-description 'specify: %d'
zstyle ':completion:*' completer _expand _complete _correct _approximate
zstyle ':completion:*' format 'Completing %d'
zstyle ':completion:*' group-name ''
zstyle ':completion:*' menu select=2
if whence dircolors >/dev/null; then
  eval "$(dircolors -b)"
  zstyle ':completion:*:default' list-colors ${(s.:.)LS_COLORS}
  alias ls='ls --color'
else
  export CLICOLOR=1
  zstyle ':completion:*:default' list-colors ''
fi
zstyle ':completion:*' list-colors ''
zstyle ':completion:*' list-prompt %SAt %p: Hit TAB for more, or the character to insert%s
zstyle ':completion:*' matcher-list '' 'm:{a-z}={A-Z}' 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=* l:|=*'
zstyle ':completion:*' menu select=long
zstyle ':completion:*' select-prompt %SScrolling active: current selection at %p%s
zstyle ':completion:*' use-compctl false
zstyle ':completion:*' verbose true

zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#)*=0=01;31'
zstyle ':completion:*:kill:*' command 'ps -u $USER -o pid,%cpu,tty,cputime,cmd'

# oh-my-zsh
export ZSH="$HOME/.oh-my-zsh"   
ZSH_THEME="robbyrussell"
plugins=(git)
source $ZSH/oh-my-zsh.sh

# Custom
export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin:${KREW_ROOT:-$HOME/.krew}/bin:$HOME/.local/bin
. "$HOME/.cargo/env"
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
# eval "$(starship init zsh)"
command -v flux >/dev/null && . <(flux completion zsh)
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
case `uname` in
  Darwin)
    eval "$(/opt/homebrew/bin/brew shellenv)"
    source $(brew --prefix)/opt/powerlevel10k/powerlevel10k.zsh-theme
    . /opt/homebrew/etc/profile.d/z.sh
  ;;
  Linux)
    eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
    source ~/powerlevel10k/powerlevel10k.zsh-theme
    . $HOME/z.sh
  ;;
esac
eval $(thefuck --alias duck)