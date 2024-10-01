# エイリアスの読み込み
if [ -f ~/.zsh_aliases ]; then
    source ~/.zsh_aliases
fi

# 環境変数の読み込み
if [ -f ~/.zsh_exports ]; then
    source ~/.zsh_exports
fi

# for M1 mac
if [[ "$OSTYPE" == "darwin"* ]]; then
  eval $(/opt/homebrew/bin/brew shellenv)
fi

# vscodeとcursorのエディタを分ける
if [ "$EDITOR" = "code" ]; then
    git config --global core.editor "code -w"
else
    git config --global core.editor "cursor -w"
fi

# 起動時にカレンダー表示
cal
