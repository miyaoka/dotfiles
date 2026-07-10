#!/usr/bin/env bash
#
# mise を更新し、管理下のシステムパッケージとツールをインストール/更新

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

# mise のインストール
install_mise() {
  log_info "mise をインストール中..."
  if command -v mise >/dev/null 2>&1; then
    # self-update は GitHub API を使うためレート制限で失敗することがある
    mise self-update --yes || log_warn "mise self-update に失敗しました（続行します）"
  else
    curl https://mise.run | sh
    log_info "mise のインストールが完了しました"
  fi
}

# メイン処理
main() {
  echo "=== mise ==="
  install_mise

  echo ""
  echo "=== system packages ==="
  # [bootstrap.packages] のパッケージを mise 内蔵の brew バックエンドで導入・更新
  # （Homebrew 本体は不要。apply = 未導入の導入、upgrade = 導入済みの更新）
  log_info "システムパッケージをインストール中..."
  mise bootstrap packages apply --yes
  log_info "システムパッケージを更新中..."
  mise bootstrap packages upgrade --yes

  echo ""
  echo "=== tools ==="
  log_info "mise で管理するツールをインストール中..."
  mise install

  echo ""
  log_info "インストール完了"
  command -v git >/dev/null 2>&1 && echo "  git: $(git --version)"
  command -v mise >/dev/null 2>&1 && echo "  mise: $(mise --version)"
}

# スクリプト実行
main "$@"
