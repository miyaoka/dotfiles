# zsh

## history
export HISTSIZE=10000
export SAVEHIST=10000
setopt hist_expire_dups_first # 履歴を切り詰める際に、重複する最も古いイベントから消す
setopt hist_ignore_all_dups   # 履歴が重複した場合に古い履歴を削除する
setopt hist_ignore_dups       # 前回のイベントと重複する場合、履歴に保存しない
setopt hist_save_no_dups      # 履歴ファイルに書き出す際、新しいコマンドと重複する古いコマンドは切り捨てる
setopt share_history          # 全てのセッションで履歴を共有する

# brew
export PATH="/home/linuxbrew/.linuxbrew/bin:$PATH"
export BROWSER=wslview

# starship
export STARSHIP_CONFIG=~/.config/starship/starship.toml
eval "$(starship init zsh)"

# fzf
export FZF_DEFAULT_OPTS='--border --height 70% --color=fg+:11 --reverse --exit-0 --exact  --ignore-case'

