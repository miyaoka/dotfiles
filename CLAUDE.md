# CLAUDE.md

このファイルはリポジトリでコードを扱う際に Claude Code（claude.ai/code）へガイダンスを提供する

## リポジトリ概要

シェル設定ファイルとセットアップスクリプトを含む個人用 dotfiles リポジトリ。主な目的は、設定ファイルを適切なシステムディレクトリにシンボリックリンクを作成すること

## インストール

インストールスクリプトを実行してシンボリックリンクを作成：

```bash
sh install.sh
```

このスクリプトは：

- `zsh/.zshenv`をホームディレクトリにリンク
- `zsh/.zshrc`を`~/.config/zsh/`にリンク
- `git/`配下のファイルを`~/.config/git/`にリンク
- `starship/`配下のファイルをを`~/.config/starship/`にリンク
- `mise/`配下のファイルをを`~/.config/mise/`にリンク

## ファイル構成

- `install.sh` - シンボリックリンクを作成するメインインストールスクリプト
- `git/` - Git 設定ファイル群
- `zsh/` - Zsh 設定ファイル群
- `starship/` - Starship 設定ファイル群
- `mise/` - mise ランタイム管理ツール設定

## 設定内容

### zsh 設定

- `.zshenv` - ZDOTDIR 設定で zsh 設定ファイルを`~/.config/zsh/`に配置
- `.zshrc` - メイン設定ファイル、他設定ファイルを読み込み
- `config.zsh` - zsh コア設定（setopt、履歴管理）
- `exports.zsh` - 環境変数設定
- `aliases.zsh` - コマンドエイリアス（git、パッケージマネージャー、ツール）
- `functions.zsh` - カスタムシェル関数
- `keybindings.zsh` - キーバインド設定
- `tools.zsh` - 外部ツール初期化（brew、mise、starship、pnpm）

### git 設定

- `ignore` - グローバル ignore
- `config` - グローバル config
- `alias.conf` - エイリアスとワークフロー設定

### その他ツール

- `starship` - プロンプト設定
- `mise` - ランタイムバージョン管理ツール設定

## ファイル読み込み順序

`.zshrc` で以下の順序で設定ファイルを読み込む：

1. `config.zsh` - zsh 基本設定
2. `exports.zsh` - 環境変数
3. `aliases.zsh` - エイリアス
4. `functions.zsh` - 関数
5. `keybindings.zsh` - キーバインド
6. `tools.zsh` - 外部ツール初期化
