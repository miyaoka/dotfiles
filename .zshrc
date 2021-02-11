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

# yarn
export PATH="$PATH:`yarn global bin`"

# starship
export STARSHIP_CONFIG=~/.starship.toml
eval "$(starship init zsh)"

# history
setopt hist_ignore_all_dups
setopt share_history

# fzf
export FZF_DEFAULT_OPTS='--border --color=fg+:11 --reverse --exit-0 --multi'
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

function ff() {
  local dir
  dir=$(find ${1:-.} -maxdepth 4 -mindepth 1 -type d ! -path '*/.*' -a ! -path '*/node_modules/*' | fzf)
  cd "$dir"
}
