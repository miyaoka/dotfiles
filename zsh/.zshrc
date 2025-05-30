# 実行中スクリプトの実体ディレクトリを取得
local _dotfiles_dir=${${(%):-%x}:A:h}

# zshコア設定の読み込み
if [ -f "$_dotfiles_dir/config.zsh" ]; then
    source "$_dotfiles_dir/config.zsh"
fi

# 環境変数の読み込み
if [ -f "$_dotfiles_dir/exports.zsh" ]; then
    source "$_dotfiles_dir/exports.zsh"
fi

# エイリアスの読み込み
if [ -f "$_dotfiles_dir/aliases.zsh" ]; then
    source "$_dotfiles_dir/aliases.zsh"
fi

# 関数の読み込み
if [ -f "$_dotfiles_dir/functions.zsh" ]; then
    source "$_dotfiles_dir/functions.zsh"
fi

# 外部ツール初期化（遅延読み込み）
if [ -f "$_dotfiles_dir/tools.zsh" ]; then
    source "$_dotfiles_dir/tools.zsh"
fi

