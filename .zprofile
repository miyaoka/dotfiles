if [[ "$OSTYPE" == "darwin"* ]]; then
  # for M1 mac
  eval $(/opt/homebrew/bin/brew shellenv)
fi

alias ll='ls -alG'
alias ..='cd ..'
alias ...="cd ../.."
alias ....="cd ../../.."
alias .....="cd ../../../.."
alias c='code'
alias cc='ghq list | fzf --preview "head -100 $(ghq root)/{}/package.json" | xargs -I {} code $(ghq root)/{}'
alias g='git'
alias q='ghq'
function qg (){
  local repo=$(echo ${1} | sed s%https://github.com/%%)
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
alias yuil='yarn upgrade-interactive --latest'

alias yd='yarn dev'
alias ys='yarn serve'
alias yb='yarn build'
alias yrn='cat package.json | jq -r ".scripts | keys[]" | fzf | xargs yarn'

alias ss='serve -s'
