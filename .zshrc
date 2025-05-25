# エイリアスの読み込み
if [ -f ~/.config/zsh/.zsh_aliases ]; then
    source ~/.config/zsh/.zsh_aliases
fi

# 環境変数の読み込み
if [ -f ~/.config/zsh/.zsh_exports ]; then
    source ~/.config/zsh/.zsh_exports
fi

# 関数の読み込み
if [ -f ~/.config/zsh/.zsh_functions ]; then
    source ~/.config/zsh/.zsh_functions
fi

# for M1 mac
if [[ "$OSTYPE" == "darwin"* ]]; then
  eval $(/opt/homebrew/bin/brew shellenv)
fi

# mise
eval "$(~/.local/bin/mise activate zsh)"

# pnpm
export PNPM_HOME="/home/miyaoka/.local/share/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac
# pnpm end
