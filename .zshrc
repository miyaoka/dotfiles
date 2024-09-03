# brew
export PATH="/home/linuxbrew/.linuxbrew/bin:$PATH"
export BROWSER=wslview

# nvm
# export NVM_DIR="$HOME/.nvm"
# [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm

# # run `nvm use` automatically
# enter_directory() {
#   if [[ $PWD == $PREV_PWD ]]; then
#     return
#   fi

#   PREV_PWD=$PWD
#   [[ -f ".nvmrc" ]] && nvm use
# }
# export PROMPT_COMMAND=enter_directory
# precmd() { eval "$PROMPT_COMMAND" }

# yarn
export PATH="$PATH:`yarn global bin`"

# starship
export STARSHIP_CONFIG=~/.starship.toml
eval "$(starship init zsh)"

# history
export HISTFILE=~/.zsh_history
export HISTSIZE=10000
export SAVEHIST=10000
setopt hist_expire_dups_first # 履歴を切り詰める際に、重複する最も古いイベントから消す
setopt hist_ignore_all_dups   # 履歴が重複した場合に古い履歴を削除する
setopt hist_ignore_dups       # 前回のイベントと重複する場合、履歴に保存しない
setopt hist_save_no_dups      # 履歴ファイルに書き出す際、新しいコマンドと重複する古いコマンドは切り捨てる
setopt share_history          # 全てのセッションで履歴を共有する

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

# 起動時にカレンダー表示
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
alias ccc='ghq list | fzf --preview "head -100 $(ghq root)/{}/package.json" | xargs -I {} code -r $(ghq root)/{}'
alias g='git'
alias q='ghq'
function qg (){
  local repo=$(echo ${1} | sed s%https://github.com/%%)
  ghq get "https://github.com/${repo}.git"
}
alias ql='ghq list'
# https://sancho.dev/blog/better-yarn-npm-run
function ys (){
  if cat package.json > /dev/null 2>&1; then
    scripts=$(cat package.json | jq .scripts | sed '1d;$d' | fzf)
 
    if [[ -n $scripts ]]; then
      script_name=$(echo $scripts | awk -F ': ' '{gsub(/(\s|")/, "", $1); print $1}')
      echo $script_name
      print -s "yarn run "$script_name;
      yarn run $script_name
    else
      echo "Exit: You haven't selected any script"
    fi
else
    echo "Error: There's no package.json"
fi
}

alias gb='gh browse'
alias gp='gh pr list'
# author: me
alias gpm='gh pr list -A @me'
# review-requested: me
alias gpmr='gh pr list --search "review-requested:@me"'
alias gpf='gh pr list | fzf | awk "{ print \$1 }"'
alias gpw="gpf | xargs gh pr view --web"
alias gpc="gpf | xargs gh pr checkout"

# alias n='npm'
# alias nr='npm run'
# alias ni='npm i'
# alias nid='npm i -D'
# alias nu='npm un'

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
# alias ys='cat package.json | jq -r ".scripts | keys[]" | fzf | xargs yarn'

alias p='pnpm'
alias pi='pnpm i'
alias pa='pnpm add'
alias pad='pnpm add -D'
alias pr='pnpm remove'
alias pw='pnpm why'
alias pui='pnpm up -i'
alias pd='pnpm run dev'
alias pdo='pnpm run dev --open'
alias pagp='pnpm add -g pnpm'

alias ss='serve -s'

# https://prettier.io/docs/en/watching-files.html
alias prw='echo prettier watching... && npx onchange "**/*" -- npx prettier --write --ignore-unknown {{changed}}'

export VOLTA_HOME="$HOME/.volta"
export PATH="$VOLTA_HOME/bin:$PATH"

# pnpm
export PNPM_HOME="/home/miyaoka/.local/share/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac
# pnpm end
