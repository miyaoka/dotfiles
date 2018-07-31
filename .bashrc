export CLICOLOR=1
export LSCOLORS=DxGxcxdxCxegedabagacad
export NDK_ROOT=/Applications/android-ndk-r10c
export ANDROID_SDK_ROOT=/Applications/adt-bundle-mac-x86_64-20140702/sdk
export HISTCONTROL="ignoredups"

###-tns-completion-start-###
if [ -f /Users/miyaoka/.tnsrc ]; then
    source /Users/miyaoka/.tnsrc
fi
###-tns-completion-end-###
PATH="/usr/local/opt/coreutils/libexec/gnubin:$PATH"
MANPATH="/usr/local/opt/coreutils/libexec/gnuman:$MANPATH"
[ -f /usr/local/etc/bash_completion ] && . /usr/local/etc/bash_completion
which direnv > /dev/null 2>&1 && eval "$(direnv hook bash)"
which kubectl > /dev/null 2>&1 && source <(kubectl completion bash)
[ -f ${HOME}/google-cloud-sdk/path.bash.inc ] && source "${HOME}/google-cloud-sdk/path.bash.inc"
[ -f ${HOME}/google-cloud-sdk/completion.bash.inc ] && source "${HOME}/google-cloud-sdk/completion.bash.inc"
