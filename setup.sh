#!/bin/bash

# セットアップスクリプト
# Homebrew と mise で必要なツールをインストール

set -e # エラー時に終了

# 色定義
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# ログ出力関数
log_info() {
  printf "${GREEN}[INFO]${NC} %s\n" "$1"
}

log_warn() {
  printf "${YELLOW}[WARN]${NC} %s\n" "$1"
}

log_error() {
  printf "${RED}[ERROR]${NC} %s\n" "$1"
}

# Homebrew のインストール確認
check_brew() {
  if ! command -v brew >/dev/null 2>&1; then
    log_error "Homebrew がインストールされていません"
    log_info "以下のコマンドでインストールしてください:"
    echo '/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"'
    exit 1
  fi
  log_info "Homebrew が見つかりました: $(brew --version | head -n1)"
}

# brew ツールのインストール
install_brew_tool() {
  local tool=$1
  local formula=${2:-$tool} # 第2引数がなければ第1引数を使用

  if command -v "$tool" >/dev/null 2>&1; then
    log_info "$tool は既にインストールされています"
  else
    log_info "$formula をインストール中..."
    if brew install "$formula"; then
      log_info "$formula のインストールが完了しました"
    else
      log_error "$formula のインストールに失敗しました"
      return 1
    fi
  fi
}

# mise のインストール
install_mise() {
  if command -v mise >/dev/null 2>&1; then
    log_info "mise は既にインストールされています: $(mise --version)"
    log_info "mise を更新中..."
    mise self-update
  else
    log_info "mise をインストール中..."
    curl https://mise.run | sh
    log_info "mise のインストールが完了しました"
  fi
}

# メイン処理
main() {
  log_info "セットアップを開始します"

  # Homebrew の確認
  check_brew

  # Homebrew の更新
  log_info "Homebrew を更新中..."
  brew update

  # brew ツールをインストール
  BREW_TOOLS=(
    "git:git"
  )

  for tool_spec in "${BREW_TOOLS[@]}"; do
    IFS=':' read -r tool formula <<<"$tool_spec"
    install_brew_tool "$tool" "$formula"
  done

  # mise のインストール
  install_mise

  # mise で管理するツールをインストール
  log_info "mise で管理するツールをインストール中..."
  mise install

  log_info "全てのツールのインストールが完了しました"

  # インストール済みツールの確認
  log_info "インストール済みツールのバージョン:"
  command -v git >/dev/null 2>&1 && echo "  git: $(git --version)"
  command -v mise >/dev/null 2>&1 && echo "  mise: $(mise --version)"
}

# スクリプト実行
main "$@"
