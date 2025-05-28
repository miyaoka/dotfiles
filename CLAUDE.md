# CLAUDE.md

このファイルはリポジトリでコードを扱う際にClaude Code（claude.ai/code）へガイダンスを提供する

## リポジトリ概要

シェル設定ファイルとセットアップスクリプトを含む個人用dotfilesリポジトリ。主な目的は、設定ファイルを適切なシステムディレクトリにシンボリックリンクを作成すること

## インストール

インストールスクリプトを実行してシンボリックリンクを作成：

```bash
./install.sh
```

このスクリプトは：
- `zsh/.zshenv`をホームディレクトリにリンク
- `zsh/`配下のファイルを`~/.config/zsh/`にリンク
- `git/`配下のファイルを`~/.config/git/`にリンク
- `starship/.starship.toml`を`~/.config/`にリンク
- `mise/config.toml`を`~/.config/mise/`にリンク

## ファイル構成

- `install.sh` - シンボリックリンクを作成するメインインストールスクリプト
- `git/` - Git設定ファイル群
- `zsh/` - Zsh設定ファイル群
- `starship/` - Starship設定ファイル群
- `mise/config.toml` - miseランタイム管理ツール設定

## 設定内容

### zsh設定
- `.zshenv` - ZDOTDIR設定でzsh設定ファイルを`~/.config/zsh/`に配置
- `.zshrc` - メイン設定ファイル、他設定ファイルを読み込み
- `.zsh_aliases` - コマンドエイリアス（git、パッケージマネージャー、ツール）
- `.zsh_exports` - 環境変数設定
- `.zsh_functions` - カスタムシェル関数

### git設定
- `.gitconfig` - 豊富なエイリアスとワークフロー設定
- `.gitignore` - グローバルignoreパターン

### その他ツール
- `starship` - プロンプト設定
- `mise` - ランタイムバージョン管理ツール設定