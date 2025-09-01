# dotfiles

シェル設定ファイルとセットアップスクリプトを含む個人用 dotfiles リポジトリ。主な目的は、設定ファイルを適切なシステムディレクトリにシンボリックリンクを作成すること

## セットアップ手順

### 初回セットアップ

必要なツールをインストール：

```bash
sh setup.sh
```

このスクリプトは Homebrew を使用して以下のツールをインストール：

- git
- gh (GitHub CLI)
- ghq (リポジトリ管理)
- mise (ランタイムバージョン管理)
- starship (プロンプト)

### 設定ファイルの同期

シンボリックリンクを作成して設定ファイルを同期：

```bash
sh sync.sh
```

このスクリプトは `home/` ディレクトリ内の全ファイルをホームディレクトリに再帰的にシンボリックリンクを作成

## ファイル構成

- `setup.sh` - 必要なツールをインストールする初回セットアップスクリプト
- `sync.sh` - シンボリックリンクを作成する同期スクリプト
- `home/` - ホームディレクトリに配置するファイル群
  - `.zshenv` - ホーム直下に配置（ZDOTDIR 設定）
  - `.config/` - ~/.config/ に配置
    - `git/` - Git 設定ファイル群
    - `zsh/` - Zsh 設定ファイル群
    - `starship/` - Starship 設定ファイル群
    - `mise/` - mise ランタイム管理ツール設定
    - `tmux/` - tmux 設定ファイル群

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

### tmux 設定

- `tmux.conf` - tmux メイン設定ファイル（キーバインド、外観、マウス操作など）

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

## クロスプラットフォーム対応方針

この dotfiles は Linux、macOS、BSD 系環境で動作するよう設計されている

### 環境依存コマンドの回避

以下のコマンドは環境により動作が異なるため使用禁止：

- `head -n -1` → `sed '$d'` を使用（最後の行削除）
- `tail -r` → `tac` または環境判定で代替（逆順出力）
- `grep -P` → 基本正規表現または `rg` を使用
- `date -d` → `date -j` との違いを考慮
- `readlink -f` → 環境判定で `realpath` と使い分け

### 環境判定パターン

```zsh
# 逆順出力の例（functions.zsh の revcat 関数）
if command -v tac >/dev/null 2>&1; then          # GNU coreutils
  tac "$@"
elif tail -r /dev/null >/dev/null 2>&1; then     # BSD tail
  tail -r "$@"
else                                             # POSIX代替
  awk '{ buf[NR]=$0 } END { for (i=NR;i>0;i--) print buf[i] }' "$@"
fi
```

### POSIX 準拠の推奨

環境依存を避けるため、可能な限り POSIX 準拠コマンドを使用する
