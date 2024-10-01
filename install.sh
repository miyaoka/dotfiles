#!/bin/sh
wd=$(pwd)
ln -sf ${wd}/.gitconfig ~/.gitconfig
ln -sf ${wd}/.zshrc ~/.zshrc
ln -sf ${wd}/.zsh_aliases ~/.zsh_aliases
ln -sf ${wd}/.zsh_exports ~/.zsh_exports
ln -sf ${wd}/.starship.toml ~/.starship.toml
