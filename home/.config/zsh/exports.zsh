# 環境変数設定

export PATH="$HOME/.local/bin:$PATH"

# bun
export PATH="$HOME/.bun/bin:$PATH"

# CONFIG DIR
# export XDG_CONFIG_HOME="$HOME/.config"

# codex
export CODEX_HOME="$HOME/.config/codex"

# export CLAUDE_CONFIG_DIR="$XDG_CONFIG_HOME/claude"

# ブラウザ・エディタ
if [[ -n "$WSL_DISTRO_NAME" ]]; then
  # WSL環境
  export BROWSER="explorer.exe"
  export EDITOR="code -w"
elif [[ "$(uname)" == "Darwin" ]]; then
  # macOS環境
  export BROWSER="open"
  export EDITOR=hx
else
  # その他Linux環境
  export BROWSER="xdg-open"
  export EDITOR=hx
fi


# fzf
export FZF_DEFAULT_OPTS='
  --border
  --height 70%
  --color=fg+:11
  --reverse
  --exit-0
  --exact
  --ignore-case
  --tiebreak=index
  --bind shift-tab:toggle-all
'

