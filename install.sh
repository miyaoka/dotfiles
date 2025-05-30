#!/bin/sh
wd=$(pwd)

# シンボリックリンクを作成

## zshenvはrootにしか置けない
ln -sf ${wd}/zsh/.zshenv ~/.zshenv

## ~/.config下に配置 

### zsh（zshenvでZDOTDIR設定）
mkdir -p ~/.config/zsh
ln -sf ${wd}/zsh/.zshrc ~/.config/zsh/.zshrc

### git
mkdir -p ~/.config/git
ln -sf ${wd}/git/.gitconfig ~/.config/git/config
ln -sf ${wd}/git/.gitignore ~/.config/git/ignore

### starship
mkdir -p ~/.config/starship
ln -sf ${wd}/starship/starship.toml ~/.config/starship/starship.toml

### mise
mkdir -p ~/.config/mise
ln -sf ${wd}/mise/config.toml ~/.config/mise/config.toml
