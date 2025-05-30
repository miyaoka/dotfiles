# 実行中スクリプトの実体ディレクトリを取得
local _dotfiles_dir=${${(%):-%x}:A:h}

# エイリアスの読み込み
if [ -f "$_dotfiles_dir/aliases.zsh" ]; then
    source "$_dotfiles_dir/aliases.zsh"
fi

# 環境変数の読み込み
if [ -f "$_dotfiles_dir/exports.zsh" ]; then
    source "$_dotfiles_dir/exports.zsh"
fi

# 関数の読み込み
if [ -f "$_dotfiles_dir/functions.zsh" ]; then
    source "$_dotfiles_dir/functions.zsh"
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
