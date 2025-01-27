#!/usr/bin/env bash

target=$(mktemp)
tar cJf "$target" .
cp "$target" nix-starter-kit.tar.xz
