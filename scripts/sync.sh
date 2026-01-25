#!/bin/sh
#
# ./home/ 配下のファイルをホームディレクトリにシンボリックリンクで配置
# ~/.config 配下のリンク先が存在しないシンボリックリンクを削除（それ以外は手動削除）
# 新規追加・削除のみを差分表示

script_dir="$(cd "$(dirname "$0")/.." && pwd)"
src_dir="$script_dir/home"
dest_dir="$HOME"

# homeディレクトリ内の全ファイル・ディレクトリを処理
synced=$(find "$src_dir" -mindepth 1 | while read item; do
  # 相対パスを取得
  rel_path="${item#$src_dir/}"
  dest_item="$dest_dir/$rel_path"

  if [ -d "$item" ]; then
    # ディレクトリの場合は作成のみ
    mkdir -p "$dest_item"
  elif [ -f "$item" ]; then
    # 既に同じリンク先を指している場合はスキップ
    if [ -L "$dest_item" ] && [ "$(readlink "$dest_item")" = "$item" ]; then
      continue
    fi
    # ファイルの場合はシンボリックリンクを作成
    # fオプションで既存ファイルが存在していても強制上書きする
    ln -sf "$item" "$dest_item"
    echo "$dest_item"
  fi
done)

# .config配下のリンク先が存在しないシンボリックリンクを削除
deleted=$(find "$dest_dir/.config" -type l ! -exec test -e {} \; -print -delete 2>/dev/null)

GREEN='\033[32m'
RED='\033[31m'
RESET='\033[0m'

if [ -n "$synced" ]; then
  echo "$synced" | while read line; do
    printf "${GREEN}+ %s${RESET}\n" "$line"
  done
fi

if [ -n "$deleted" ]; then
  echo "$deleted" | while read line; do
    printf "${RED}- %s${RESET}\n" "$line"
  done
fi

if [ -z "$synced" ] && [ -z "$deleted" ]; then
  echo "Everything up-to-date"
fi
