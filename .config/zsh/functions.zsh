# カスタム関数

# ファイル内容を逆順出力
# 環境によりtacかtail -rを使う
revcat() {
  if command -v tac >/dev/null 2>&1; then          # GNU coreutils 環境
    tac "$@"
  elif tail -r /dev/null >/dev/null 2>&1; then     # BSD tail -r が使える環境
    tail -r "$@"
  else                                             # どちらも無い場合は awk で代替
    awk '{ buf[NR]=$0 } END { for (i=NR;i>0;i--) print buf[i] }' "$@"
  fi
}

# port番号でプロセスをkillする
killp() {
  if [ -z "$1" ]; then
    echo "Usage: killp <port>"
    return 1
  fi
  kill -9 $(lsof -ti :"$1") 2>/dev/null && echo "Killed process on port $1" || echo "No process found on port $1"
}

# org/repo 形式または URL を受け取って ghq get する
ghq-clone() {
  # 引数チェック：何も指定がなければ使い方を表示して終了
  if [ $# -lt 1 ]; then
    echo "Usage: repo-get <org/repo> | <git URL>" >&2
    return 1
  fi

  local target="$1"

  # 引数が URL (https://... or git@...) ならそのまま、そうでなければ github.com/<org/repo> とする
  if [[ "$target" =~ ^https?:// ]] || [[ "$target" =~ ^git@ ]]; then
    ghq get "$target"
  else
    ghq get "github.com/${target}"
  fi
}

# ghq で管理しているリポジトリをfzfで選択し、パスをechoする
# 選択履歴を保存して次回は優先表示する
# -f オプションで頻度順表示
ghq-select() {
  local frequency_mode=false
  
  # -f オプションチェック
  if [[ "$1" == "-f" ]]; then
    frequency_mode=true
    shift
  fi

  # 選択履歴保存先
  local histfile="$HOME/.config/.ghq_fzf_history"
  # ghq root
  local ghq_root
  ghq_root=$(ghq root | head -n1) || return
  # fzf の選択結果 (ghq rootからの相対)         
  local rel     
  # 絶対パス
  local abs

  # fzf 用オプションを配列で定義
  local -a fzf_opts=(
    # 最新を上に表示
    --reverse
    # プレビューサイズ設定
    --preview-window=right:40%
    # プレビューに README.md の最初の200行を表示
    --preview="head -n200 ${ghq_root}/{}/README.md 2>/dev/null || echo 'No README.md'"
    # github.com/ 以降の部分のみを表示（/区切りで2列目以降）
    --with-nth="2.."
    --delimiter="/"
  )
  
  # タイトルを設定
  if [ "$frequency_mode" = true ]; then
    fzf_opts+=(--header="ghq repositories (frequency order)")
  else
    fzf_opts+=(--header="ghq repositories (recent order)")
  fi

  # 1) 選択結果を rel に代入
  rel=$(
    # サブシェル開始：履歴と ghq list を結合
    (
      if [ -f "$histfile" ]; then
        if [ "$frequency_mode" = true ]; then
          # 頻度順（使用回数の多い順）で出力
          sort "$histfile" | uniq -c | sort -nr | awk '{print $2}'
        else
          # 新しいものから逆順に出力
          revcat "$histfile"
        fi
      fi
      # ghq 管理下のリポジトリを相対パスで一覧表示
      ghq list
    ) |
    # 重複行を除去し、初出の行だけを通過させる
    awk '!seen[$0]++' |
    # fzf でインタラクティブに選択
    fzf "${fzf_opts[@]}"
  ) || return  # キャンセル時は関数を終了

  # 2) 履歴に追記
  echo "$rel" >> "$histfile"

  # 3) 選択したパスをechoする
  abs="${ghq_root}/${rel}"
  if [ -d "$abs" ]; then
    echo "$abs"
  else
    echo "Repository not found: $rel"
    echo "Removing from history..."
    # 履歴から削除
    if [ -f "$histfile" ]; then
      grep -v "^${rel}$" "$histfile" > "${histfile}.tmp" && mv "${histfile}.tmp" "$histfile"
    fi
    return 1
  fi
}

# ghq-selectの結果でエディタを開く
ghq-edit() {
  local selected
  selected=$(ghq-select "$@")
  
  if [[ $? -eq 0 && -n "$selected" ]]; then
    ${EDITOR:-code} "$selected"
  fi
}

# ghq-selectの結果でcdする
ghq-cd() {
  local selected
  selected=$(ghq-select "$@")
  
  if [[ $? -eq 0 && -n "$selected" ]]; then
    cd "$selected"
  fi
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