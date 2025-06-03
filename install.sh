#!/bin/sh
wd=$(pwd)

# フォルダ内のファイルを指定先にリンクする関数
link_dir() {
  local src_dir="$1"
  local dest_dir="$2"
  
  mkdir -p "$dest_dir"
  find "${wd}/${src_dir}" -type f | while read file; do
    # 相対パスを取得してディレクトリ構造を保持
    rel_path=$(echo "$file" | sed "s|${wd}/${src_dir}/||")
    dest_file="$dest_dir/$rel_path"
    dest_subdir=$(dirname "$dest_file")
    
    echo "Creating link: $file -> $dest_file"
    mkdir -p "$dest_subdir"
    ln -sf "$file" "$dest_file"
  done
}

# シンボリックリンクを作成

## zshenvはrootにしか置けない
ln -sf ${wd}/zsh/.zshenv ~/.zshenv

## ~/.config下に配置 

### zsh（zshenvでZDOTDIR設定）
mkdir -p ~/.config/zsh
ln -sf ${wd}/zsh/.zshrc ~/.config/zsh/.zshrc

### config directories
link_dir "git" ~/.config/git
link_dir "starship" ~/.config/starship
link_dir "mise" ~/.config/mise
link_dir "tmux" ~/.config/tmux
