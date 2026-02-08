# カスタム関数

# port番号でプロセスをkillする
killp() {
  if [ -z "$1" ]; then
    echo "Usage: killp <port>"
    return 1
  fi
  kill -9 $(lsof -ti :"$1") 2>/dev/null && echo "Killed process on port $1" || echo "No process found on port $1"
}

# 履歴選択（純粋関数）
_select_history() {
  history -rn 1 | awk '!seen[$0]++' | fzf \
    --header="Command history" \
    --query="$1"
}

# ディレクトリ選択（純粋関数）
# dirsの内容はcdrに含まれるが、dirsを優先表示することで現在セッションの移動履歴が上に来る
_select_dirs() {
  local work_paths
  local history_paths
  local merged_paths

  # work: 現在セッションの作業用ディレクトリスタック
  work_paths=$(dirs -p)

  # history: 全セッション共有の移動履歴
  history_paths=$(cdr -l 2>/dev/null | awk '{print $2}')

  # workとhistoryを結合して重複除去
  merged_paths=$(
    (
      echo "$work_paths"
      echo "$history_paths"
    ) | awk 'NF && !seen[$0]++'
  )

  # fzfで選択
  echo -e "$merged_paths" | fzf \
    --header="Directory navigation"
}

# 履歴をfzfで検索して実行（通常関数）
fzf_history() {
  local selected
  selected=$(_select_history)

  if [[ $? -eq 0 && -n "$selected" ]]; then
    eval "$selected"
  fi
}

# ディレクトリ移動履歴をfzfで選択してcd（通常関数）
fzf_dirs() {
  local selected
  selected=$(_select_dirs)

  if [[ $? -eq 0 && -n "$selected" ]]; then
    # チルダを展開してcdする
    eval "cd $selected"
  fi
}

# 現在ブランチのprをdifitで開く
difit-pr() {
  # 現在のブランチ名を取得
  local current_branch=$(git branch --show-current)

  # ghコマンドでPRを検索（現在ブランチのPR）
  local pr_url=$(gh pr view "$current_branch" --json url -q .url 2>/dev/null)

  if [[ -n "$pr_url" ]]; then
    # PRが存在する場合、URLを指定してdifitを実行
    bunx difit --pr "$pr_url"
  else
    echo "No PR found for branch: $current_branch"
    return 1
  fi
}

# bunxに自動で@latestを付けるラッパー関数
bunx-latest() {
  local cmd="$1"
  shift

  # バージョン指定がない場合は@latestを付ける
  if [[ "$cmd" != *"@"* ]]; then
    cmd="${cmd}@latest"
  fi

  command bunx "$cmd" "$@"
}

# ==== alias選択関数群 ====

# aliasの一覧をfzfで表示し、previewで展開内容を表示
zsh_alias() {
  local selected
  selected=$(alias | sed "s/'\\\\''/'/g" | fzf \
    --header="Alias list" \
    --delimiter='=' \
    --preview='
      # alias名を取得
      alias_name={1}
      # 値を取得（2番目以降のフィールド）
      alias_value={2..}
      
      echo "[$alias_name]"
      # 前後のクォートを除去
      echo "$alias_value" | sed "s/^'"'"'//;s/'"'"'$//"
    ' \
    --preview-window='up:3:wrap' | cut -d= -f1)

  # 選択されたalias名を返す
  [[ -n "$selected" ]] && echo "$selected"
}

# gitのalias一覧をfzfで表示し、previewで展開内容を表示
git_alias() {
  local selected
  selected=$(git config --get-regexp '^alias\.' | sed 's/^alias\.//' | fzf \
    --header="Git alias list" \
    --delimiter=' ' \
    --preview='
      # alias名を取得
      alias_name={1}
      # 値を取得（2番目以降のフィールド）
      alias_value={2..}
      
      echo "[git $alias_name]"
      echo "$alias_value"
    ' \
    --preview-window='up:3:wrap' | cut -d' ' -f1)

  # 選択されたalias名を返す（git付き）
  [[ -n "$selected" ]] && echo "git ${selected}"
}

# git discard: 変更ファイルと新規ファイルを選択して破棄
function git-discard-files() {
  local files
  # ファイルリストに色とタグを付ける
  local colored_files=$(
    {
      git ls-files -m | while read -r f; do echo -e "\033[33m[M]\033[0m $f"; done
      git ls-files -o --exclude-standard | while read -r f; do echo -e "\033[31m[U]\033[0m $f"; done
    }
  )

  # discard対象のファイルがない場合は早期リターン
  if [[ -z "$colored_files" ]]; then
    echo "No files to discard"
    return 0
  fi

  # fzfで選択（色付き表示、ファイル名だけ抽出）
  files=$(echo "$colored_files" |
    fzf -m --ansi \
      --preview 'f=$(echo {} | sed "s/^.*\] //"); (git diff --color=always "$f" | grep . || cat "$f")' \
      --header 'Select files to discard' |
    sed 's/^.*\] //')

  [[ -z "$files" ]] && return 0

  # 影響を受けるファイルを表示
  echo "The following files will be discarded:"
  echo "----"
  echo "$files" | while read -r file; do
    if git ls-files --error-unmatch "$file" >/dev/null 2>&1; then
      echo "\033[33m[M]\033[0m $file" # 黄色
    else
      echo "\033[31m[U]\033[0m $file" # 赤色
    fi
  done
  echo "----"

  # 確認
  echo "Continue?"
  read confirm

  # 実行
  echo "$files" | while read -r file; do
    if git ls-files --error-unmatch "$file" >/dev/null 2>&1; then
      # tracked file -> use restore
      git restore "$file"
      echo "Restored: $file"
    else
      # untracked file -> use clean (quiet mode)
      git clean -fq -- "$file"
      echo "Removed: $file"
    fi
  done
}

# https://github.com/cli/cli/issues/6089#issuecomment-1220250908
# .zshrc gh pr list command extended with fzf, see the man page (man fzf) for an explanation of the arguments.
function gp {
  [[ ! "$(git rev-parse --is-inside-work-tree)" ]] && return 1
  GH_COMMAND='gh pr list -L 50 \
  --json number,author,updatedAt,title \
  --template "
	{{- tablerow (\"PR\" | color \"blue+b\") (\"LAST UPDATE\" | color \"blue+b\") (\"AUTHOR\" | color \"blue+b\") (\"TITLE\" | color \"blue+b\") -}}
	{{- range . -}}
		{{- tablerow (printf \"#%v\" .number | color \"green+h\") (timeago .updatedAt | color \"gray+h\") (.author.login | color \"cyan+h\") .title -}}
	{{- end -}}" \
  --search'
  FZF_DEFAULT_COMMAND="$GH_COMMAND ${1:-\"\"}" \
    GH_FORCE_TTY=100% fzf --ansi --header-lines=1 \
    --header $'CTRL+o - Browser | CTRL+s - Switch' \
    --prompt 'Search Open PRs >' \
    --bind 'ctrl-o:execute-silent(gh pr view {1} --web)' \
    --bind 'ctrl-s:become(gh pr checkout {1})'
}

# Renovate の open PR を CI 結果付きで一覧表示
# 引数: なし=自分の全リポジトリ, owner=指定ownerの全リポジトリ, owner/repo=特定リポジトリ
gh-renovate-prs() {
  local scope
  if [[ -z "$1" ]]; then
    local owner
    owner=$(gh api user --jq '.login') || return
    scope="owner:$owner"
  elif [[ "$1" == */* ]]; then
    scope="repo:$1"
  else
    scope="owner:$1"
  fi

  gh api graphql \
    -f searchQuery="author:app/renovate $scope is:pr is:open" \
    -f query='
      query($searchQuery: String!) {
        search(query: $searchQuery, type: ISSUE, first: 100) {
          nodes {
            ... on PullRequest {
              url
              title
              commits(last: 1) {
                nodes {
                  commit {
                    statusCheckRollup {
                      state
                    }
                  }
                }
              }
            }
          }
        }
      }' \
    --jq '.data.search.nodes[] |
      [
        (.commits.nodes[0].commit.statusCheckRollup.state // "NONE"),
        .url,
        .title
      ] | @tsv' |
    sort |
    while IFS=$'\t' read -r state url title; do
      case "$state" in
      SUCCESS) printf '\033[32m%-10s\033[0m %s  %s\n' "pass" "$url" "$title" ;;
      PENDING) printf '\033[33m%-10s\033[0m %s  %s\n' "pending" "$url" "$title" ;;
      NONE) printf '\033[90m%-10s\033[0m %s  %s\n' "no checks" "$url" "$title" ;;
      *) printf '\033[31m%-10s\033[0m %s  %s\n' "fail" "$url" "$title" ;;
      esac
    done
}

# mise: tracked config からツールを選択し、使用している config を表示
mise-tracked-usage() {
  # 各 tracked config のディレクトリで mise ls --json を実行し、source があるエントリを収集
  local data=$(mise config ls --tracked-configs | while read -r config; do
    local dir=$(dirname "$config")
    mise ls --json -C "$dir" 2>/dev/null | jq -r '
      to_entries[] |
      .key as $tool |
      .value[] |
      select(has("source")) |
      "\(.source.path)\t\($tool)@\(.version)"
    '
  done | sort -u)

  # ツール@バージョンのユニークリストを fzf で選択（preview で使用 config を表示）
  local selected=$(echo "$data" | cut -f2 | sort -u | fzf --header="mise-tracked-usage" --preview="echo \"$data\" | grep -F {} | cut -f1 | sed \"s|$HOME|~|g\"")
  [[ -z "$selected" ]] && return

  # 選択されたツール@バージョンを使用している config を表示
  echo "\033[36m$selected\033[0m"
  echo "$data" | grep -F "$selected" | cut -f1 | sed "s|$HOME|~|g"
}
