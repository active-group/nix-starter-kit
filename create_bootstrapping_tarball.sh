#!/usr/bin/env bash

set -e

if [[ $# != 1 ]]; then
    echo "Usage:  ./$(basename "$0") TARGET_DIR"
    exit 1
fi

if [ ! -d "$1" ]; then
    echo "Target directory '$1' does not exist"
    exit 2
fi

tmp=$(mktemp)
tar cJf "$tmp" .
cp "$tmp" "$1"/nix-starter-kit.tar.xz
