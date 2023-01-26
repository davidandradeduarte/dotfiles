#             __
# ____  _____/ /_  __________
#/_  / / ___/ __ \/ ___/ ___/
# / /_(__  ) / / / /  / /__
#/___/____/_/ /_/_/   \___/

# --
# zsh config
# --

# zmodload zsh/zprof # profiling

export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="robbyrussell"

zstyle ":omz:update" mode disabled # disable automatic updates

export HISTFILE=~/.zsh_history
export HISTFILESIZE=1000000000
export HISTSIZE=1000000000
export HISTORY_IGNORE="(ls|l|ll|cd|pwd|exit|clear|co|vo|cdo|rgf|proclist|cd ..|..|*rlivings39.fzf-quick-open*)"

setopt INC_APPEND_HISTORY
setopt EXTENDED_HISTORY
setopt HIST_FIND_NO_DUPS
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_IGNORE_SPACE
setopt GLOBDOTS # include hidden files in completions

plugins=(
   zsh-autosuggestions
   git
   docker
   kubectl
   fzf-tab
   vi-mode
   zsh-vimode-visual
   forgit
   fast-syntax-highlighting
   # zsh-syntax-highlighting # disabled; trying fast-syntax-highlighting instead
   # web-search # disabled; not been using it lately
)
fpath+=${ZSH_CUSTOM:-${ZSH:-~/.oh-my-zsh}/custom}/plugins/zsh-completions/src

source $ZSH/oh-my-zsh.sh

# --
# user config
# --

# variables
source ~/.env.private
source ~/.env.work

export LANG=pt_PT.UTF-8
export HOMEBREW_NO_AUTO_UPDATE=1
export HOMEBREW_NO_ANALYTICS=1
export DOTNET_CLI_TELEMETRY_OPTOUT=0
# export LS_COLORS="$(vivid generate molokai)" # disabled; using static colors for now
export LS_COLORS="di=1;36:ln=35:so=32:pi=33:ex=31:bd=34;46:cd=34;43:su=30;41:sg=30;46:tw=30;42:ow=30;43"
export XDG_CONFIG_HOME=$HOME/.config
export FZF_DEFAULT_OPTS=" --history=$HOME/.fzf-history --height 90% --layout=reverse"\
" --color=fg:-1,bg:-1,hl:#78ff98"\
" --color=fg+:#d0d0d0,bg+:#262626,hl+:#53ff79"\
" --color=info:#d19a66,prompt:#d7005f,pointer:#ffaa33"\
" --color=marker:#87ff00,spinner:#ffaa33,header:#61afef"
fzf_excluded=(
   ".git"
   ".Trash"
   "Library"
   ".npm"
   "go/pkg/mod"
   ".docker"
   "Music/Music"
   ".oh-my-zsh"
   ".local/share"
   ".terminfo"
   ".vscode/extensions"
   "Pictures/Photos\ Library.photoslibrary/"
   ".azure/cliextensions"
   ".tldrc"
   ".cache"
   ".zsh_sessions"
   ".terraform.d"
   ".azure"
   ".nix-defexpr"
   ".rustup"
   ".kube/cache"
   ".kube/http-cache"
)
fzf_command="fd --type f --hidden --follow"
for i in $fzf_excluded; do
   fzf_command="$fzf_command -E $i"
done
export FZF_DEFAULT_COMMAND="$fzf_command"

if [[ -n $SSH_CONNECTION ]]; then
   export EDITOR="vim"
else
   export EDITOR="nvim"
fi

# aliases
alias _vim="/usr/bin/vim"
alias _cat="/bin/cat"
alias _curl="/usr/bin/curl"
alias _code="/opt/homebrew/bin/code"
alias vi="nvim"
alias vim="nvim"
alias code="code -a"
alias cat="bat -p"
alias curl="curlie"
alias l="gls -lhaG --color --group-directories-first"
alias ll="exa -la --group-directories-first"
alias lg="lazygit"
alias find="fd"
alias kc="kubectx"
alias kn="kubens"
alias cheat="cheat -c"
alias zsh_reload="source ~/.zshrc"
alias _ipp="ifconfig en0| grep \"inet[ ]\" | awk '{print \$2}'"
alias _ip="dig +short myip.opendns.com @resolver1.opendns.com"

# custom functions and scripts
for file in $HOME/.bin/*.sh; do
   source "$file"
done
export PATH=$PATH:$HOME/.bin

# eval "$(starship init zsh)" # disabled; using zsh theme default prompt

# sources/evals/completions
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
. /opt/homebrew/etc/profile.d/z.sh
export PATH="$PATH:$HOME/source/misc/git-fuzzy/bin"
eval $(thefuck --alias)
. <(flux completion zsh)

# completion settings
zstyle ":completion:*" special-dirs
zstyle ":completion:*" list-colors ${(s.:.)LS_COLORS}
# fzf-tab
zstyle ":fzf-tab:complete:cd:*" fzf-preview "exa -a -1 --color=always $realpath"
zstyle ":fzf-tab:*" fzf-command ftb-tmux-popup
zstyle ":fzf-tab:complete:cd:*" popup-pad 50 10
zstyle ":fzf-tab:*" popup-min-size 60 20