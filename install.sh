#!/bin/sh

src_dir="$(pwd)/home"
dest_dir="$HOME"

# homeディレクトリ内の全ファイル・ディレクトリを処理
find "$src_dir" -mindepth 1 | while read item; do
  # 相対パスを取得
  rel_path="${item#$src_dir/}"
  dest_item="$dest_dir/$rel_path"
  
  if [ -d "$item" ]; then
    # ディレクトリの場合は作成のみ
    mkdir -p "$dest_item"
  elif [ -f "$item" ]; then
    # ファイルの場合はシンボリックリンクを作成
    echo "Creating link: $item -> $dest_item"
    ln -sf "$item" "$dest_item"
  fi
done