# -----------------------------------------------------------------
# general
# -----------------------------------------------------------------
alias ll='ls -alG'
alias ..='cd ..'

alias h="history"

# -----------------------------------------------------------------
# 自作function
# -----------------------------------------------------------------

# ghq
alias gc='ghq-clone'
alias cc='ghq-edit'
alias ccd='ghq-cd'

#git
alias gd="git-discard-files"

# difit
alias dp="difit-pr"

# aliasをリストから選択してコマンドラインに挿入
#（引数をつけて実行できるように末尾に空白を入れておく）
alias z@='print -z "$(zsh_alias) "' 
alias g@='print -z "$(git_alias) "' 

# -----------------------------------------------------------------
# tools
# -----------------------------------------------------------------
# git
alias g='git'

# clone
alias degit="tiged"

# gh
alias gp='gh pr list'
## author: me
alias gpa='gh pr list --author @me --json number,createdAt,title,headRefName | jq -r ".[] | \"\(.number)\t\(.createdAt | fromdateiso8601 | strflocaltime(\"%Y-%m-%d %H:%M\"))\t\(.title)\t\(.headRefName)\"" | fzf --with-nth=1..3 --delimiter=$'\''\t'\'' | cut -f4 | xargs git switch'
## review-requested: me
alias gpr='gh pr list --search "review-requested:@me" --json number,createdAt,title,headRefName | jq -r ".[] | \"\(.number)\t\(.createdAt | fromdateiso8601 | strflocaltime(\"%Y-%m-%d %H:%M\"))\t\(.title)\t\(.headRefName)\"" | fzf --with-nth=1..3 --delimiter=$'\''\t'\'' | cut -f4 | xargs git switch'

# pnpm
alias p='pnpm'
alias pi='pnpm i'
alias pa='pnpm add'
alias pad='pnpm add -D'
alias pui='pnpm up -i'

# ni
alias nii='ni -i'
alias r='nr'

# editor
alias c='code'

# mise
alias m='mise'

# rm
alias rmn='rm -rf **/node_modules'

# deno
alias d='deno'
alias dt='deno task'
alias dr='deno run'

# deno script
# alias r='uni-run'

# bun
alias b='bun'
alias x='bunx'
alias xx='bunx-latest'

# claude
alias @='claude'
alias @v='claude --verbose'
alias @@='claude-session-resume'
alias @@o='claude-session-open'
alias @c='chrome-debug'

# codex
alias o='codex'
alias oo='codex resume'

# oh-my-logo
alias logo="bunx oh-my-logo@latest --filled"
