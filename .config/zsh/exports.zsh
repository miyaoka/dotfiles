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
export BROWSER=wslview


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
