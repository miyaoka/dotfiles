# 対話シェルでも # をコメントにする
setopt interactive_comments

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

# ghq で管理しているリポジトリをfzfで選択し、引数で指定したコマンドで実行する
# 選択履歴を保存して次回は優先表示する
# -f オプションで頻度順表示
ghq-select() {
  local frequency_mode=false
  
  # -f オプションチェック
  if [[ "$1" == "-f" ]]; then
    frequency_mode=true
    shift
  fi
  
  # 開くコマンド（引数があればそれを、なければ $EDITOR）
  local opener="${1:-${EDITOR}}"

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
          tac "$histfile"
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

  # 3) 引数で指定したコマンドで開く
  abs="${ghq_root}/${rel}"
  if [ -d "$abs" ]; then
    "$opener" "$abs"
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

# 履歴から除外するコマンド（基本名のみ）
_excluded_commands=(
  "ls"           # ls系コマンド
  "ll"
  "la"
  "l"
  "cd"           # ディレクトリ移動
  "pwd"          # 現在ディレクトリ表示
  "clear"        # 画面クリア
  "cls"
  "exit"         # 終了
  "history"      # 履歴表示
  "bg"           # バックグラウンド処理
  "fg"
  "jobs"
  "ps"           # プロセス表示
  "htop"
  "top"
  "man"          # マニュアル表示
  "help"
  "which"        # コマンドパス表示
  "type"
  "echo"         # 簡単な出力
  "cat"          # ファイル表示
  "less"
  "more"
  "head"
  "tail"
)

# 配列を正規表現パターンに変換（引数ありパターンも自動生成）
_history_exclude_regex=$(printf "|%s" "${_excluded_commands[@]}")
_history_exclude_regex="^(${_history_exclude_regex:1})(\s.*)?$"

# 履歴から除外するコマンドのフィルタリング
zshaddhistory() {
  # コマンドラインから先頭の空白と改行を除去
  local cmd="${1%$'\n'}"
  cmd="${cmd#"${cmd%%[![:space:]]*}"}"
  
  
  # 正規表現でマッチチェック
  if [[ "$cmd" =~ $_history_exclude_regex ]]; then
    return 1  # 履歴に追加しない
  fi
  
  # 実行するコマンドを記録（エラー時の削除用）
  _last_command="$cmd"
  
  return 0  # 履歴に追加する
}

# コマンド実行後に呼ばれる - エラーの場合は履歴から削除
precmd() {
  # 前回のコマンドの終了ステータスを保存
  local last_exit_status=$?
  
  # 前回のコマンドがエラーだった場合
  if [[ $last_exit_status -ne 0 && -n "$_last_command" ]]; then
    # 履歴ファイルから最後の行を削除（メモリには残す）
    if [[ -w "$HISTFILE" && -f "$HISTFILE" ]]; then
      # 一時ファイルを使って最後の行以外をコピー
      head -n -1 "$HISTFILE" > "${HISTFILE}.tmp" && mv "${HISTFILE}.tmp" "$HISTFILE"
    fi
  fi
  
  # コマンド記録をクリア
  _last_command=""
}
