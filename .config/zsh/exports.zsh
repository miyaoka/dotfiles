# 環境変数設定

# CONFIG DIR
# export XDG_CONFIG_HOME="$HOME/.config"
# export CLAUDE_CONFIG_DIR="$XDG_CONFIG_HOME/claude"

# claude
export PATH="$HOME/.claude/local:$PATH"

# bun
export PATH="$HOME/.bun/bin:$PATH"

# brew
export PATH="/home/linuxbrew/.linuxbrew/bin:$PATH"

# ブラウザ
if [[ -n "$WSL_DISTRO_NAME" ]]; then
  # WSL環境
  export BROWSER="explorer.exe"
elif [[ "$(uname)" == "Darwin" ]]; then
  # macOS環境
  export BROWSER="open"
else
  # その他Linux環境
  export BROWSER="xdg-open"
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

# vscode
export EDITOR=code
