#!/bin/bash
#
# brew と mise を更新し、管理下のツールをインストール/更新

set -e # エラー時に終了

# 色定義
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# ログ出力関数
log_info() {
  printf "${GREEN}%s${NC}\n" "$1"
}

log_warn() {
  printf "${YELLOW}%s${NC}\n" "$1"
}

log_error() {
  printf "${RED}%s${NC}\n" "$1"
}

# Homebrew のインストール確認
check_brew() {
  if ! command -v brew >/dev/null 2>&1; then
    log_error "Homebrew がインストールされていません"
    log_info "以下のコマンドでインストールしてください:"
    echo '/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"'
    exit 1
  fi
}

# brew ツールのインストールまたは更新
install_brew_tool() {
  local tool=$1
  local formula=${2:-$tool} # 第2引数がなければ第1引数を使用

  log_info "$tool をインストール中..."
  if brew list "$formula" >/dev/null 2>&1; then
    if brew outdated "$formula" | grep -q "$formula"; then
      brew upgrade "$formula"
    else
      log_info "$tool is up to date"
    fi
  else
    if brew install "$formula"; then
      log_info "$tool のインストールが完了しました"
    else
      log_error "$tool のインストールに失敗しました"
      return 1
    fi
  fi
}

# mise のインストール
install_mise() {
  log_info "mise をインストール中..."
  if command -v mise >/dev/null 2>&1; then
    # self-update は GitHub API を使うためレート制限で失敗することがある
    mise self-update || log_warn "mise self-update に失敗しました（続行します）"
  else
    curl https://mise.run | sh
    log_info "mise のインストールが完了しました"
  fi
}

# メイン処理
main() {
  echo "=== brew ==="
  check_brew
  log_info "Homebrew をインストール中..."
  brew update

  BREW_TOOLS=(
    "git:git"
  )

  for tool_spec in "${BREW_TOOLS[@]}"; do
    IFS=':' read -r tool formula <<<"$tool_spec"
    install_brew_tool "$tool" "$formula"
  done

  echo ""
  echo "=== mise ==="
  install_mise

  log_info "mise で管理するツールをインストール中..."
  mise install

  echo ""
  log_info "インストール完了"
  command -v git >/dev/null 2>&1 && echo "  git: $(git --version)"
  command -v mise >/dev/null 2>&1 && echo "  mise: $(mise --version)"
}

# スクリプト実行
main "$@"
