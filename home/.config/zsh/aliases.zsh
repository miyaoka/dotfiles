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
alias d='difit'
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

# gh
alias ghp='gh pr list'
alias ghb="gh browse"
## pr: author: me
alias ghpa='gh pr list --author @me --json number,createdAt,title,headRefName | jq -r ".[] | \"\(.number)\t\(.createdAt | fromdateiso8601 | strflocaltime(\"%Y-%m-%d %H:%M\"))\t\(.title)\t\(.headRefName)\"" | fzf --with-nth=1..3 --delimiter=$'\''\t'\'' | cut -f4 | xargs -I {} sh -c "git fetch && git switch {}"'
## pr: review-requested: me
alias ghpr='gh pr list --search "review-requested:@me" --json number,createdAt,title,headRefName | jq -r ".[] | \"\(.number)\t\(.createdAt | fromdateiso8601 | strflocaltime(\"%Y-%m-%d %H:%M\"))\t\(.title)\t\(.headRefName)\"" | fzf --with-nth=1..3 --delimiter=$'\''\t'\'' | cut -f4 | xargs -I {} sh -c "git fetch && git switch {}"'
## issue: author: me
alias ghi='gh issue list --author @me --json number,createdAt,title | jq -r ".[] | \"\(.number)\t\(.createdAt | fromdateiso8601 | strflocaltime(\"%Y-%m-%d %H:%M\"))\t\(.title)\"" | fzf | cut -f1 | xargs -I {} gh issue view {} --web'

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
alias mi='mise install'
alias mu='mise up'
alias msu='mise self-update'
alias mo='mise outdated --bump'
## tracked-config (~/.local/state/mise/tracked-configs/): mise が認識している config ファイルの一覧
alias mtc='mise config ls --tracked-configs'
## tracked-config: ツール@バージョンを選択し、どの config で使われているか表示
alias mtu='mise-tracked-usage'

# rm
alias rmn='rm -rf **/node_modules'

# bun
alias b='bun'

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
