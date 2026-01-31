# ghq 関連の共有設定
GHQ_SELECT_HISTFILE="$HOME/.cache/.ghq_fzf_history"

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

# ファイル内容を逆順出力
# 環境によりtacかtail -rを使う
revcat() {
  if command -v tac >/dev/null 2>&1; then # GNU coreutils 環境
    tac "$@"
  elif tail -r /dev/null >/dev/null 2>&1; then # BSD tail -r が使える環境
    tail -r "$@"
  else # どちらも無い場合は awk で代替
    awk '{ buf[NR]=$0 } END { for (i=NR;i>0;i--) print buf[i] }' "$@"
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

  local histfile="$GHQ_SELECT_HISTFILE"
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
  ) || return # キャンセル時は関数を終了

  # 2) 履歴に追記
  echo "$rel" >>"$histfile"

  # 3) 選択したパスをechoする
  abs="${ghq_root}/${rel}"
  if [ -d "$abs" ]; then
    echo "$abs"
  else
    echo "Repository not found: $rel"
    echo "Removing from history..."
    # 履歴から削除
    if [ -f "$histfile" ]; then
      grep -v "^${rel}$" "$histfile" >"${histfile}.tmp" && mv "${histfile}.tmp" "$histfile"
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

# 古いリポジトリを選択して削除
ghq-prune() {
  local ghq_root
  ghq_root=$(ghq root | head -n1) || return

  local selected
  selected=$(
    ghq list -p | while read d; do
      printf '%s\t%s\n' "$(date -d @$(stat -c %Y "$d") +%Y-%m-%d)" "${d#$ghq_root/}"
    done | sort | fzf --multi --header="Select repositories to remove (oldest first)" | cut -f2
  ) || return

  if [[ -z "$selected" ]]; then
    echo "No repositories selected."
    return
  fi

  echo "Removing:"
  echo "$selected" | sed 's/^/  /'
  echo ""
  read "reply?Are you sure? (Y/n) "
  [[ "$reply" =~ ^[nN]$ ]] && return

  local histfile="$GHQ_SELECT_HISTFILE"

  echo "$selected" | while read r; do
    rm -rf "${ghq_root}/${r}"
    if [[ -f "$histfile" ]]; then
      grep -v "^${r}$" "$histfile" >"${histfile}.tmp" && mv "${histfile}.tmp" "$histfile"
    fi
    echo "Removed ${r}"
  done
}
