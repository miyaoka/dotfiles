# PROMPT="[\A] \[\e[32m\]\`prompt_pwd\`\[\e[m\]\[\e[35m\]\`parse_git_branch\`\[\e[m\] > "

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

export PATH="$PATH:`yarn global bin`"
export FZF_DEFAULT_OPTS='--border --color=fg+:11 --reverse --exit-0 --multi'
# '--layout=reverse --border'

eval "$(starship init zsh)"