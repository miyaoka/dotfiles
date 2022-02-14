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