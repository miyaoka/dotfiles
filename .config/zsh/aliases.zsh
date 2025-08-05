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
## カレントブランチでブラウザを開く
alias gho='gh browse --branch $(git cbn)'
alias ghp='gh pr list'
## author: me
alias ghpm='gh pr list -A @me'
## review-requested: me
alias ghpmr='gh pr list --search "review-requested:@me"'
alias ghpf='gh pr list | fzf | awk "{ print \$1 }"'
alias ghpw="ghpf | xargs gh pr view --web"
alias ghpc="ghpf | xargs gh pr checkout"

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
alias npx='bunx'
alias x='bunx'
alias xx='bunx-latest'

# claude
alias @='claude'
alias @v='claude --verbose'
alias @@='claude-session-resume'
alias @@o='claude-session-open'

# oh-my-logo
alias logo="bunx oh-my-logo@latest --filled"
