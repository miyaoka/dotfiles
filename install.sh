#!/bin/sh
wd=$(pwd)

# シンボリックリンクを作成

## zshenvはrootにしか置けない
ln -sf ${wd}/.zshenv ~/.zshenv

## ~/.config下に配置 

### git
mkdir -p ~/.config/git
ln -sf ${wd}/.gitconfig ~/.config/git/config
ln -sf ${wd}/.gitignore ~/.config/git/ignore

### zsh
mkdir -p ~/.config/zsh
ln -sf ${wd}/.zshrc ~/.config/zsh/.zshrc
ln -sf ${wd}/.zsh_aliases ~/.config/zsh/.zsh_aliases
ln -sf ${wd}/.zsh_exports ~/.config/zsh/.zsh_exports
ln -sf ${wd}/.zsh_functions ~/.config/zsh/.zsh_functions

### starship
ln -sf ${wd}/.starship.toml ~/.config/.starship.toml
