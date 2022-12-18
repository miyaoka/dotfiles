# brew
export PATH="/home/linuxbrew/.linuxbrew/bin:$PATH"

# nvm
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm

# run `nvm use` automatically
enter_directory() {
  if [[ $PWD == $PREV_PWD ]]; then
    return
  fi

  PREV_PWD=$PWD
  [[ -f ".nvmrc" ]] && nvm use
}
export PROMPT_COMMAND=enter_directory
precmd() { eval "$PROMPT_COMMAND" }

# yarn
export PATH="$PATH:`yarn global bin`"

# starship
export STARSHIP_CONFIG=~/.starship.toml
eval "$(starship init zsh)"

# history
export HISTFILE=~/.zsh_history
export SAVEHIST=1000
setopt hist_ignore_all_dups
setopt share_history

# fzf
export FZF_DEFAULT_OPTS='--border --height 70% --color=fg+:11 --reverse --exit-0'
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

function ff() {
  local dir
  dir=$(find ${1:-.} -maxdepth 4 -mindepth 1 -type d ! -path '*/.*' -a ! -path '*/node_modules/*' | fzf)
  cd "$dir"
}

if [[ -n "$IS_WSL" || -n "$WSL_DISTRO_NAME" ]]; then
  alias open=explorer.exe
fi

cal


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
