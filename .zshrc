# エイリアスの読み込み
if [ -f ~/.config/zsh/.zsh_aliases ]; then
    source ~/.config/zsh/.zsh_aliases
fi

# 環境変数の読み込み
if [ -f ~/.config/zsh/.zsh_exports ]; then
    source ~/.config/zsh/.zsh_exports
fi

# for M1 mac
if [[ "$OSTYPE" == "darwin"* ]]; then
  eval $(/opt/homebrew/bin/brew shellenv)
fi

# mise
eval "$(~/.local/bin/mise activate zsh)"

# port番号でプロセスをkillする
killp() {
  if [ -z "$1" ]; then
    echo "Usage: killp <port>"
    return 1
  fi
  kill -9 $(lsof -ti :"$1") 2>/dev/null && echo "Killed process on port $1" || echo "No process found on port $1"
}

# vscodeとcursorのエディタを分ける
# if [ "$EDITOR" = "code" ]; then
#     git config --global core.editor "code -w"
# else
#     git config --global core.editor "cursor -w"
# fi

# 起動時にカレンダー表示
cal
