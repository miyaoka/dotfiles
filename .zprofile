# eval $(/opt/homebrew/bin/brew shellenv)

alias ll='ls -alG'
alias ..='cd ..'
alias ...="cd ../.."
alias ....="cd ../../.."
alias .....="cd ../../../.."
alias c='code'
alias cc='ghq list | fzf | xargs -I {} code $(ghq root)/{}'
alias g='git'
alias q='ghq'
function qg (){
  local repo
  repo=$(echo ${1} | sed s%https://github.com/%%)
  echo "git clone: ${repo}"
  ghq get "https://github.com/${repo}.git"
}
alias ql='ghq list'

alias n='npm'
alias nr='npm run'
alias ni='npm i'
alias nid='npm i -D'
alias nu='npm un'

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

alias yd='yarn dev'
alias ys='yarn serve'
alias yrn='cat package.json | jq -r ".scripts | keys[]" | fzf | xargs yarn'
