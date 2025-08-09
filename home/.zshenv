export ZDOTDIR="$HOME/.config/zsh"

# env.local
# ──────────────────────────────────────────
# 実行中スクリプトの実体ディレクトリを取得
local _dotfiles_dir=${${(%):-%x}:A:h}

# 同じディレクトリ内の .zshenv.local を読み込む
local _local_env="${_dotfiles_dir}/.zshenv.local"
[ -r "${_local_env}" ] && source "${_local_env}"
# ──────────────────────────────────────────