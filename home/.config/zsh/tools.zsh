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

# starship
export STARSHIP_CONFIG=~/.config/starship/starship.toml
eval "$(starship init zsh)"
