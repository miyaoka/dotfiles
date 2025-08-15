# fzf関連のキーバインド設定

# 履歴をfzfで検索して実行（zle用）
_zle_fzf_history() {
  local selected
  selected=$(_select_history "$LBUFFER")
  
  # fzfが正常終了（選択）した場合のみコマンドを設定
  if [[ $? -eq 0 && -n "$selected" ]]; then
    LBUFFER="$selected"   # 選択されたコマンドをカーソル左側に設定
    RBUFFER=""           # カーソル右側をクリア
  fi
  
  # プロンプトを再描画して正常な状態に戻す
  zle reset-prompt
}

# ディレクトリ移動履歴をfzfで選択してcd（zle用）
_zle_fzf_dirs() {
  local selected
  selected=$(_select_dirs)
  
  # fzfが正常終了した場合のみ移動
  if [[ $? -eq 0 && -n "$selected" ]]; then
    # 通常のcdで移動
    BUFFER="cd ${selected}"
    zle accept-line
  fi
  
  # 画面をクリアして再描画
  zle clear-screen
}

# git quicksave実行（zle用）
_zle_git_quicksave() {
  # コマンドラインが空の場合のみ実行
  if [[ -z "$BUFFER" ]]; then
    BUFFER="git qs"
    zle accept-line
  fi
}

# zle関数を登録
zle -N _zle_fzf_history
zle -N _zle_fzf_dirs
zle -N _zle_git_quicksave

# キーバインド設定
bindkey '^r' _zle_fzf_history  # Ctrl+r で履歴検索
bindkey '^t' _zle_fzf_dirs    # Ctrl+d でディレクトリ選択
bindkey '^s' _zle_git_quicksave # Ctrl+s で git quicksave
