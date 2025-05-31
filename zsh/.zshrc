# 実行中スクリプトの実体ディレクトリを取得
local _dotfiles_dir=${${(%):-%x}:A:h}

# 設定ファイルの読み込み
for file in "$_dotfiles_dir"/*.zsh; do
    [[ -f "$file" ]] && source "$file"
done

