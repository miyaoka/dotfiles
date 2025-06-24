# zsh コア設定

# 対話シェルでも # をコメントにする
setopt interactive_comments

# history 設定
export HISTSIZE=10000 # メモリ内履歴数
export SAVEHIST=10000 # ファイル保存履歴数
export HISTFILE="${ZDOTDIR:-$HOME}/.zsh_history"  # 履歴ファイルの場所を明示的に指定

setopt hist_expire_dups_first # 履歴を切り詰める際に、重複する最も古いイベントから消す
setopt hist_ignore_all_dups   # 履歴が重複した場合に古い履歴を削除する
setopt hist_save_no_dups      # 履歴ファイルに書き出す際、新しいコマンドと重複する古いコマンドは切り捨てる
setopt hist_reduce_blanks     # 履歴保存時に余分な空白を削除
setopt hist_verify            # 履歴展開時に編集可能状態で表示（!!等）
setopt inc_append_history     # コマンド実行時に即座に履歴追加
setopt share_history          # 全てのセッションで履歴を共有する

# 補完・入力関連
setopt auto_menu              # TAB連打で補完候補を順次選択
setopt auto_list              # 補完候補を自動表示
setopt auto_param_slash       # ディレクトリ名補完時に末尾に/を追加
setopt magic_equal_subst      # =以降でも補完有効（--prefix=/usr等）

# ディレクトリ操作
# pushd/dirs: セッション固有の一時的なディレクトリスタック（ワークスペース内作業用）
setopt auto_pushd             # cd時に自動でpushd
setopt pushd_ignore_dups      # pushd時の重複ディレクトリを無視

# cdr: 全セッション共有の永続的なディレクトリ履歴（プロジェクト間移動用）
# 保存場所: $ZDOTDIR/.chpwd-recent-dirs、保持件数: DIRSTACKSIZE変数で設定（デフォルト20件）
autoload -Uz chpwd_recent_dirs cdr add-zsh-hook
add-zsh-hook chpwd chpwd_recent_dirs
DIRSTACKSIZE=50  # cdr履歴の保持件数を50件に変更

# グロブ・パターン
setopt extended_glob          # 拡張glob（^、#等）を有効
setopt glob_dots              # .で始まるファイルもglob対象

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
  ".."
)

# 配列を正規表現パターンに変換（引数ありパターンも自動生成）
_history_exclude_regex=$(printf "|%s" "${_excluded_commands[@]}")
_history_exclude_regex="^(${_history_exclude_regex:1})(\s.*)?$"

# 履歴制御: メモリには残すがファイル保存を選択的に行う
zshaddhistory() {
  # コマンドラインから先頭の空白と改行を除去
  local cmd="${1%$'\n'}"
  cmd="${cmd#"${cmd%%[![:space:]]*}"}"
  
  # 除外対象コマンド（ls, cd等）の場合
  if [[ "$cmd" =~ $_history_exclude_regex ]]; then
    _exclude_from_file=1  # ファイル削除フラグ設定
  else
    # 通常コマンドの場合
    _exclude_from_file=0
    _is_normal_command=1  # エラー時ファイル削除チェック対象フラグ
  fi
  
  # 全てのコマンドをメモリ＋ファイルに一旦追加
  # （後でprecmdにて条件に応じてファイルから削除）
  return 0
}

# コマンド実行後処理: ファイルからの選択的削除
precmd() {
  local last_exit_status=$?
  
  # ファイルから削除する条件判定
  local should_remove_from_file=0
  
  # 除外対象コマンド（ls, cd等）は常にファイルから削除
  if [[ $_exclude_from_file -eq 1 ]]; then
    should_remove_from_file=1
  # 通常コマンドでエラー終了した場合もファイルから削除
  elif [[ $last_exit_status -ne 0 && $_is_normal_command -eq 1 ]]; then
    should_remove_from_file=1
  fi
  
  # ファイルから最後の行を削除（メモリには残る）
  if [[ $should_remove_from_file -eq 1 && -w "$HISTFILE" && -f "$HISTFILE" ]]; then
    head -n -1 "$HISTFILE" > "${HISTFILE}.tmp" && mv "${HISTFILE}.tmp" "$HISTFILE"
  fi
  
  # 次回用にフラグをクリア
  _exclude_from_file=0
  _is_normal_command=0
}