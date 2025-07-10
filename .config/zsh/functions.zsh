# カスタム関数

# port番号でプロセスをkillする
killp() {
  if [ -z "$1" ]; then
    echo "Usage: killp <port>"
    return 1
  fi
  kill -9 $(lsof -ti :"$1") 2>/dev/null && echo "Killed process on port $1" || echo "No process found on port $1"
}

# 履歴選択（純粋関数）
_select_history() {
  history -rn 1 | awk '!seen[$0]++' | fzf \
    --header="Command history" \
    --query="$1"
}

# ディレクトリ選択（純粋関数）
# dirsの内容はcdrに含まれるが、dirsを優先表示することで現在セッションの移動履歴が上に来る
_select_dirs() {
  local work_paths
  local history_paths
  local merged_paths
  
  # work: 現在セッションの作業用ディレクトリスタック
  work_paths=$(dirs -p)
  
  # history: 全セッション共有の移動履歴
  history_paths=$(cdr -l 2>/dev/null | awk '{print $2}')
  
  # workとhistoryを結合して重複除去
  merged_paths=$(
    (
      echo "$work_paths"
      echo "$history_paths"
    ) | awk 'NF && !seen[$0]++'
  )
  
  # fzfで選択
  echo -e "$merged_paths" | fzf \
    --header="Directory navigation"
}

# 履歴をfzfで検索して実行（通常関数）
fzf_history() {
  local selected
  selected=$(_select_history)
  
  if [[ $? -eq 0 && -n "$selected" ]]; then
    eval "$selected"
  fi
}

# ディレクトリ移動履歴をfzfで選択してcd（通常関数）
fzf_dirs() {
  local selected
  selected=$(_select_dirs)
  
  if [[ $? -eq 0 && -n "$selected" ]]; then
    # チルダを展開してcdする
    eval "cd $selected"
  fi
}

# ghでprをfzfで選択してdifitで開く
difit-pr() {
  gh pr list -L 1000 --json createdAt,title,author,url,number --jq '.[] | "\(.createdAt | split("T")[0])\t\(.author.login)\t\(.title)\t\(.url)"' | fzf --delimiter=$'\t' --preview 'gh pr view {4}' --with-nth=1,2,3 | cut -f4 | xargs bunx difit --pr
}

# bunxに自動で@latestを付けるラッパー関数
bunx-latest() {
  local cmd="$1"
  shift
  
  # バージョン指定がない場合は@latestを付ける
  if [[ "$cmd" != *"@"* ]]; then
    cmd="${cmd}@latest"
  fi
  
  command bunx "$cmd" "$@"
}

# ==== alias選択関数群 ====


# aliasの一覧をfzfで表示し、previewで展開内容を表示
zsh_alias() {
  local selected
  selected=$(alias | sed "s/'\\\\''/'/g" | fzf \
    --header="Alias list" \
    --delimiter='=' \
    --preview='
      # alias名を取得
      alias_name={1}
      # 値を取得（2番目以降のフィールド）
      alias_value={2..}
      
      echo "[$alias_name]"
      # 前後のクォートを除去
      echo "$alias_value" | sed "s/^'"'"'//;s/'"'"'$//"
    ' \
    --preview-window='up:3:wrap' | cut -d= -f1)
  
  # 選択されたalias名を返す
  [[ -n "$selected" ]] && echo "$selected"
}


# gitのalias一覧をfzfで表示し、previewで展開内容を表示
git_alias() {
  local selected
  selected=$(git config --get-regexp '^alias\.' | sed 's/^alias\.//' | fzf \
    --header="Git alias list" \
    --delimiter=' ' \
    --preview='
      # alias名を取得
      alias_name={1}
      # 値を取得（2番目以降のフィールド）
      alias_value={2..}
      
      echo "[git $alias_name]"
      echo "$alias_value"
    ' \
    --preview-window='up:3:wrap' | cut -d' ' -f1)
  
  # 選択されたalias名を返す（git付き）
  [[ -n "$selected" ]] && echo "git ${selected}"
}
