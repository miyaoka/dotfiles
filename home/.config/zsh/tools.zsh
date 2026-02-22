# 外部ツール初期化

# brew
# https://docs.brew.sh/FAQ#why-should-i-install-homebrew-in-the-default-location
if [[ -d /opt/homebrew ]]; then
  # Apple Silicon Mac
  eval $(/opt/homebrew/bin/brew shellenv)
elif [[ -d /usr/local/Homebrew ]]; then
  # Intel Mac
  eval $(/usr/local/bin/brew shellenv)
elif [[ -d /home/linuxbrew/.linuxbrew ]]; then
  # Linux
  eval $(/home/linuxbrew/.linuxbrew/bin/brew shellenv)
fi

# mise
eval "$(mise activate zsh)"

# ブラウザ・エディタ
if [[ -n "$WSL_DISTRO_NAME" ]]; then
  # WSL環境
  export BROWSER="explorer.exe"
  export EDITOR="code -w"
elif [[ "$(uname)" == "Darwin" ]]; then
  # macOS環境
  export BROWSER="open"
  export EDITOR=hx
  # シェル起動時にIMEをオフ（複数ペイン同時起動時の競合回避のため遅延実行）
  { sleep 0.5 && macism com.apple.keylayout.ABC } &!
else
  # その他Linux環境
  export BROWSER="xdg-open"
  export EDITOR=hx
fi

# starship
export STARSHIP_CONFIG=~/.config/starship/starship.toml
eval "$(starship init zsh)"
