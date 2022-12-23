#!/usr/bin/env bash

set -e

if [ "$local" == "true" ] || [ "$local" == "1" ]; then
    dir=$dir shell=$shell yes=$yes local=$local \
        bash /tmp/.dotfiles/install.sh
else
    dir=$dir shell=$shell yes=$yes local=$local \
        bash <(curl -fsSL "https://raw.githubusercontent.com/davidandradeduarte/dotfiles/minimal/install.sh")
fi

if [ $? -ne 0 ]; then
    exit 1
fi
