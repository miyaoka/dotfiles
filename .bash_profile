export GOPATH=$HOME/go
export PATH=/usr/local:$PATH
export PATH=$GOPATH/bin:$PATH
export EDITOR=code

# eval "$(direnv hook bash)"

alias h='peco-history'
alias ssh='~/Dropbox/config/bin/ssh-host-color'

alias ll='ls -al'

alias c='code'
alias cc="find $(ghq root)/*/*/* -type d -prune | sed -e 's#'$(ghq root)'/##' | peco | xargs -I {} code $(ghq root)/{}"
alias t='tig'
alias g='git'
alias d='docker-compose'
alias q='ghq'
function qg (){
  echo "test, $1"
  ghq get "https://github.com/$@.git"
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
alias ygb='yarn global bin'
alias ygl='yarn global ls'
alias yga='yarn global add'
alias ygr='yarn global remove'
alias ys='yarn serve'
alias yd='yarn dev'

peco-history() {
  local NUM=$(history | wc -l)
  local FIRST=$((-1*(NUM-1)))

  if [ $FIRST -eq 0 ] ; then
    # Remove the last entry, "peco-history"
    history -d $((HISTCMD-1))
    echo "No history" >&2
    return
  fi

  local CMD=$(fc -l $FIRST | sort -k 2 -k 1nr | uniq -f 1 | sort -nr | sed -E 's/^[0-9]+[[:blank:]]+//' | peco | head -n 1)

  if [ -n "$CMD" ] ; then
    # Replace the last entry, "peco-history", with $CMD
    history -s $CMD

    if type osascript > /dev/null 2>&1 ; then
      # Send UP keystroke to console
      (osascript -e 'tell application "System Events" to keystroke (ASCII character 30)' &)
    fi

    # Uncomment below to execute it here directly
    # echo $CMD >&2
    # eval $CMD
  else
    # Remove the last entry, "peco-history"
    history -d $((HISTCMD-1))
  fi
}

# get current branch in git repo
function parse_git_branch() {
	BRANCH=`git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/\1/'`
	if [ ! "${BRANCH}" == "" ]
	then
		STAT=`parse_git_dirty`
		echo " ${BRANCH}${STAT}"
	else
		echo ""
	fi
}

# get current status of git repo
function parse_git_dirty {
	status=`git status 2>&1 | tee`
	dirty=`echo -n "${status}" 2> /dev/null | grep "modified:" &> /dev/null; echo "$?"`
	untracked=`echo -n "${status}" 2> /dev/null | grep "Untracked files" &> /dev/null; echo "$?"`
	ahead=`echo -n "${status}" 2> /dev/null | grep "Your branch is ahead of" &> /dev/null; echo "$?"`
	newfile=`echo -n "${status}" 2> /dev/null | grep "new file:" &> /dev/null; echo "$?"`
	renamed=`echo -n "${status}" 2> /dev/null | grep "renamed:" &> /dev/null; echo "$?"`
	deleted=`echo -n "${status}" 2> /dev/null | grep "deleted:" &> /dev/null; echo "$?"`
	bits=''
	if [ "${renamed}" == "0" ]; then
		bits=">${bits}"
	fi
	if [ "${ahead}" == "0" ]; then
		bits="*${bits}"
	fi
	if [ "${newfile}" == "0" ]; then
		bits="+${bits}"
	fi
	if [ "${untracked}" == "0" ]; then
		bits="?${bits}"
	fi
	if [ "${deleted}" == "0" ]; then
		bits="x${bits}"
	fi
	if [ "${dirty}" == "0" ]; then
		bits="!${bits}"
	fi
	if [ ! "${bits}" == "" ]; then
		echo " ${bits}"
	else
		echo ""
	fi
}

# get short pwd
function prompt_pwd {
	case "$PWD" in
		"$HOME") echo "~";;
		*)
			printf "%s" $(echo $PWD|sed -e "s|^$HOME|~|" -e 's-/\(\.\{0,1\}[^/]\)\([^/]*\)-/\1-g');
			echo $PWD|sed -n -e 's-.*/\.\{0,1\}.\([^/]*\)-\1-p';;
	esac;
}

export PS1="[\A] \[\e[32m\]\`prompt_pwd\`\[\e[m\]\[\e[35m\]\`parse_git_branch\`\[\e[m\] > "
# The next line updates PATH for the Google Cloud SDK.
if [ -f '/Users/miyaoka/google-cloud-sdk/path.bash.inc' ]; then source '/Users/miyaoka/google-cloud-sdk/path.bash.inc'; fi

# The next line enables shell command completion for gcloud.
if [ -f '/Users/miyaoka/google-cloud-sdk/completion.bash.inc' ]; then source '/Users/miyaoka/google-cloud-sdk/completion.bash.inc'; fi

if [ -f ~/.bashrc ]; then . ~/.bashrc; fi