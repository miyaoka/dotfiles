# -----------------------------------------------------------------
# general
# -----------------------------------------------------------------
alias ll='ls -alG'
alias ..='cd ..'
alias ...="cd ../.."
alias ....="cd ../../.."
alias .....="cd ../../../.."

alias h="history"

# -----------------------------------------------------------------
# 自作function
# -----------------------------------------------------------------

# cd
alias dd="pushd-select"

# ghq
alias gc='ghq-clone'
alias cc='ghq-edit'
alias ccd='ghq-cd'

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

# yarn
alias y='yarn'
alias ya='yarn add'
alias yad='yarn add -D'
alias yr='yarn remove'
alias yg='yarn global'
alias yga='yarn global add'
alias ygr='yarn global remove'
alias yw='yarn why'
alias yu='yarn upgrade'
alias yui='yarn upgrade-interactive'
alias yuil='yarn upgrade-interactive --latest'

alias yd='yarn dev'
alias ydo='yarn dev --open'
alias yb='yarn build'

# pnpm
alias p='pnpm'
alias pi='pnpm i'
alias pa='pnpm add'
alias pad='pnpm add -D'
alias pr='pnpm remove'
alias pw='pnpm why'
alias pui='pnpm up -i'
alias pd='pnpm run dev'
alias pdo='pnpm run dev --open'
alias pb='pnpm run build'
alias psu='pnpm self-update'
alias puil='pnpm up -i --latest'
alias pau='pnpm audit'
alias pou='pnpm outdated'

# ni
alias nii='ni -i'
alias r='nr'

# editor
alias c='code'

# mise
alias m='mise'
alias mu='mise up'
alias ml='mise ls'
alias msu='mise self-update'

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
alias bd='bun dev'
alias npx='bunx'

# claude
alias @='claude'
alias @@='claude-session-resume'
alias @@o='claude-session-open'
alias @@@='claude --dangerously-skip-permissions'

# oh-my-logo
alias logo="npx oh-my-logo@latest --filled"

# difit
alias dp=difit-pr
