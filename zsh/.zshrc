# dotfilesリポジトリのパスを取得
DOTFILES_DIR="$(dirname "$(readlink ~/.zshenv)")"

# エイリアスの読み込み
if [ -f "$DOTFILES_DIR/aliases.zsh" ]; then
    source "$DOTFILES_DIR/aliases.zsh"
fi

# 環境変数の読み込み
if [ -f "$DOTFILES_DIR/exports.zsh" ]; then
    source "$DOTFILES_DIR/exports.zsh"
fi

# 関数の読み込み
if [ -f "$DOTFILES_DIR/functions.zsh" ]; then
    source "$DOTFILES_DIR/functions.zsh"
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
