#!/usr/bin/env bash

install_url=https://raw.githubusercontent.com/davidandradeduarte/dotdot/HEAD/install

set -e

if [ "$local" == "true" ] || [ "$local" == "1" ]; then
    dir=$dir shell=$shell yes=$yes local=$local \
        /bin/bash /tmp/.dotfiles/install
else
    dir=$dir shell=$shell yes=$yes local=$local \
        /bin/bash <(curl -fsSL $install_url)
fi

if [ $? -ne 0 ]; then
    exit 1
fi
