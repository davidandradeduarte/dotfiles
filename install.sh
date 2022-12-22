#!/usr/bin/env bash

need_cmd "curl"

remote_ssh=git@github.com:davidandradeduarte/dotfiles.git
remote_https=https://github.com/davidandradeduarte/dotfiles.git
epoch=$(date +%s)
cg="\033[1;32m"
cy="\033[1;33m"
cr="\033[1;31m"
cn="\033[0m"
os=$(uname -s | tr '[:upper:]' '[:lower:]')
arch=$(uname -m | tr '[:upper:]' '[:lower:]')
distro=$(if [ "$os" == "linux" ]; then cat /etc/os-release | grep "^ID=" | cut -d "=" -f 2; else echo "macos"; fi)

inf() {
    if [ "$1" == "-n" ]; then
        command echo -ne "${cg}Info: ${cn}$2"
    else
        command echo -e "${cg}Info: ${cn}$1"
    fi
}

warn() {
    if [ "$1" == "-n" ]; then
        command echo -ne "${cy}Warning: ${cn}$2"
    else
        command echo -e "${cy}Warning: ${cn}$1"
    fi
}

err() {
    if [ "$1" == "-n" ]; then
        command echo -ne "${cr}Error: ${cn}$2"
    else
        command echo -e "${cr}Error: ${cn}$1"
    fi
}

dbg() {
    if [ "$1" == "-n" ]; then
        command echo -ne "${cd}Debug: ${cn}$2"
    else
        command echo -e "${cd}Debug: ${cn}$1"
    fi
}

_g() {
    echo -e "${cg}$@${cn}"
}

_y() {
    echo -e "${cy}$1${cn}"
}

_r() {
    echo -e "${cr}$1${cn}"
}

_c() {
    echo -e "${cd}$1${cn}"
}

symlink() {
    if [ -f "$1" ] && [ ! -L "$1" ] && [ ! "$(readlink "$1")" == "$2" ]; then
        inf "Backing up $(_g $1) to $(_g $1.bak.$epoch)"
        mv "$1" "$1.bak.$epoch"
    fi
    inf "Creating symbolic link from $(_g $2) to $(_g $1)"
    ln -sf "$2" "$1"
}

dir=${dir:-$HOME/.dotfiles}
shell=${shell:-$SHELL}
yes=${yes:-0}
local=${local:-0}

if [ "$yes" == "true" ]; then
    yes=1
fi
if [ "$local" == "true" ]; then
    local=1
fi

while [[ $# -gt 0 ]]; do
    case "$1" in
    --dir | -d)
        shift
        dir=$1
        ;;
    --shell | -s)
        shift
        shell=$1
        ;;
    --yes | -y)
        yes=1
        ;;
    --local | -l)
        local=1
        ;;
    --help | -h)
        echo "Usage: $0 [options]"
        echo ""
        echo "Options:"
        echo "  -d, --dir <dir>          Dotfiles directory (default: \$HOME/.dotfiles)"
        echo "  -s, --shell <shell>      Default shell (default: \$SHELL)"
        echo "  -y, --yes                No prompt"
        echo "  -l, --local              Local mode"
        echo "  -h, --help               Show help"
        echo ""
        echo "Example: $0 -d /location -s zsh -y -l"
        echo ""
        echo "All options are available as variables in their --name format."
        echo "The only difference is that booleans need to be set to 1 or true."
        echo "Arguments override the variables."
        echo ""
        echo "Example: dir=/location shell=zsh yes=true local=true $0"
        echo ""
        exit 0
        ;;
    *)
        err "Invalid option: $(_r $1)" >&2
        exit 1
        ;;
    esac
    shift
done

echo "---------------------------------------------"
echo -e "${cg}
          __      __  _____ __         
     ____/ /___  / /_/ __(_) /__  _____
    / __  / __ \/ __/ /_/ / / _ \/ ___/
   / /_/ / /_/ / /_/ __/ / /  __(__  ) 
   \__,_/\____/\__/_/ /_/_/\___/____/  
                                       
${cn}"
echo "---------------------------------------------"
echo -e "Directory: $(_g $dir)"
echo -e "Shell: $(_g $shell)"
echo -e "No prompt: $(_g $(if [ $yes -eq 1 ]; then echo "yes"; else echo "no"; fi))"
echo -e "Local mode: $(_g $(if [ $local -eq 1 ]; then echo "yes"; else echo "no"; fi))"
echo "---------------------------------------------"
echo -e "OS: $(_g $os)"
echo -e "Distro: $(_g $distro)"
echo -e "Arch: $(_g $arch)"
echo "---------------------------------------------"

set -e

sudo -v
if [ $? -ne 0 ]; then
    err "Aborted"
    exit 1
fi
while true; do
    sudo -n true
    sleep 60
    kill -0 "$$" || exit
done 2>/dev/null &

if [ -d "$dir" ]; then
    if [ "$(ls -A $dir)" ]; then
        if [ $yes -eq 0 ]; then
            warn -n "Directory $(_y $dir) is not empty.\nDo you want to overwrite and backup?"
            read -p " [y/N] " -n 1 -r
            echo
            if [[ $REPLY =~ ^[Yy]$ ]]; then
                inf "Backing up $(_g $dir) to $(_g $dir.old.$epoch)"
                mv "$dir" "$dir.old.$epoch"
            else
                err "Aborted"
                exit 1
            fi
        else
            mv "$dir" "$dir.old.$epoch"
            inf "Backuped old version to $(_g $dir.old.$epoch)"
        fi
    fi
fi

if [ ! -d "$(dirname "$dir")" ]; then
    err "Invalid directory: $(_r $dir)"
    exit 1
fi

if [ $local -eq 1 ]; then
    inf "Copying current directory to $(_g $dir)"
    currentdir=$(dirname "$(realpath "$0")")
    if [ ! -d "$currentdir/.git" ]; then
        err "Current directory $(_r $currentdir) is not a git repository"
        exit 1
    fi
    remote=$(git -C "$currentdir" remote get-url origin)
    if [ $remote != "$remote_https" ] && [ $remote != "$remote_ssh" ]; then
        err "Current directory $(_r $currentdir) is not a valid dotfiles repository"
        exit 1
    fi
    cp -r $currentdir "$dir"
else
    inf "Cloning repository to $(_g $dir)"
    git clone --recursive "$remote_https" "$dir"
fi

inf "Installing dotfiles for $(_g $distro)"
if [ -f "$dir/$distro/install.sh" ]; then
    . "$dir/$distro/install.sh"
else
    err "No install script for $(_r $distro)"
    exit 1
fi

inf "Cleaning up"
if [ -f /.dockerenv ]; then
    if [ -d "/tmp/.dotfiles" ]; then
        rm -rf "/tmp/.dotfiles"
    fi
    sudo rm -f "/tmp/entrypoint.sh"
fi

inf "Launching shell $(_g $shell)"
exec "$shell"

inf "Done :)"
