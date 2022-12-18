#!/bin/sh
wd=$(pwd)
ln -sf ${wd}/.gitconfig ~/.gitconfig
ln -sf ${wd}/.zshrc ~/.zshrc
ln -sf ${wd}/.starship.toml ~/.starship.toml
