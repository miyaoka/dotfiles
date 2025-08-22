#!/bin/sh

# Homebrew セットアップスクリプト
# 必要なツールをインストール

set -e  # エラー時に終了

# 色定義
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# ログ出力関数
log_info() {
    echo "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo "${RED}[ERROR]${NC} $1"
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

# ツールのインストール
install_tool() {
    local tool=$1
    local formula=${2:-$tool}  # 第2引数がなければ第1引数を使用
    
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

# メイン処理
main() {
    log_info "Homebrew セットアップを開始します"
    
    # Homebrew の確認
    check_brew
    
    # Homebrew の更新
    log_info "Homebrew を更新中..."
    brew update
    
    # 必要なツールをインストール
    TOOLS=(
        "git:git"
        "gh:gh"
        "ghq:ghq"
        "mise:mise"
        "starship:starship"
    )
    
    for tool_spec in "${TOOLS[@]}"; do
        IFS=':' read -r tool formula <<< "$tool_spec"
        install_tool "$tool" "$formula"
    done
    
    log_info "全てのツールのインストールが完了しました"
    
    # インストール済みツールの確認
    log_info "インストール済みツールのバージョン:"
    command -v git >/dev/null 2>&1 && echo "  git: $(git --version)"
    command -v gh >/dev/null 2>&1 && echo "  gh: $(gh --version | head -n1)"
    command -v ghq >/dev/null 2>&1 && echo "  ghq: $(ghq --version)"
    command -v mise >/dev/null 2>&1 && echo "  mise: $(mise --version)"
    command -v starship >/dev/null 2>&1 && echo "  starship: $(starship --version)"
}

# スクリプト実行
main "$@"