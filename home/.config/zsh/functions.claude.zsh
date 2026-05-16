# Claude関連の関数

readonly CLAUDE_PROJECTS_DIR="$HOME/.claude/projects"

# @ - profile（model + effort 組み合わせ）と new/resume を fzf で選んで claude を起動
# @ <enter> <enter> で opus medium・新規セッション起動
@() {
  local selected
  # effort ゲージ: low [▰▱▱▱▱] / medium [▰▰▱▱▱] / high [▰▰▰▱▱] / xhigh [▰▰▰▰▱] / max [▰▰▰▰▰]
  # 色: low=灰 / medium=緑 / high=黄 / xhigh=橙 / max=赤太字 (寒色→暖色のグラデーション)
  local C_LOW=$'\e[38;5;244m' C_MED=$'\e[38;5;35m' C_HI=$'\e[38;5;220m' C_XHI=$'\e[38;5;208m' C_MAX=$'\e[1;38;5;196m' C_RST=$'\e[0m'
  selected=$(printf '%s\n' \
    "${C_MED}[▰▰▱▱▱]${C_RST}"$'\t'"opus medium"$'\t'"通常実装 / 設定編集 / 長い会話継続" \
    "${C_HI}[▰▰▰▱▱]${C_RST}"$'\t'"opus high"$'\t'"設計判断 / 難バグ / 多ファイルrefactor" \
    "${C_XHI}[▰▰▰▰▱]${C_RST}"$'\t'"opus xhigh"$'\t'"長時間の自律コーディング / 繰り返しツール呼び出し / 探索的多段タスク" \
    "${C_MAX}[▰▰▰▰▰]${C_RST}"$'\t'"opus max"$'\t'"最終手段 / セキュリティ判断 / xhighで詰まった難問のみ (高コスト)" \
    "${C_LOW}[▰▱▱▱▱]${C_RST}"$'\t'"opus low"$'\t'"確認のみ / 1行修正 / リネーム" \
    "${C_HI}[▰▰▰▱▱]${C_RST}"$'\t'"sonnet high"$'\t'"[cap節約] 通常実装 (auto mode不可)" \
    "${C_MED}[▰▰▱▱▱]${C_RST}"$'\t'"sonnet medium"$'\t'"[cap節約] 軽い作業 (auto mode不可)" \
    "${C_LOW}[▰▱▱▱▱]${C_RST}"$'\t'"sonnet low"$'\t'"[cap節約] 確認のみ (auto mode不可)" | \
    fzf --ansi --prompt="profile> " --height=12 --reverse --no-sort \
        --delimiter=$'\t' --with-nth=1,2,3) || return 1

  local profile
  profile=$(echo "$selected" | cut -d$'\t' -f2)

  local args=()
  case "$profile" in
    "sonnet high")   args+=(--model sonnet --effort high) ;;
    "sonnet medium") args+=(--model sonnet --effort medium) ;;
    "sonnet low")    args+=(--model sonnet --effort low) ;;
    "opus low")      args+=(--model opus --effort low) ;;
    "opus medium")   args+=(--model opus --effort medium) ;;
    "opus high")     args+=(--model opus --effort high) ;;
    "opus xhigh")    args+=(--model opus --effort xhigh) ;;
    "opus max")      args+=(--model opus --effort max) ;;
  esac

  local mode
  mode=$(printf "new\nresume" | \
    fzf --prompt="mode> " --height=10 --reverse --no-sort) || return 1
  [[ "$mode" == "resume" ]] && args+=(--resume)

  claude "${args[@]}"
}

# ISO 8601形式の日時を指定フォーマットに変換
# 使用例: convert-iso-date "2025-08-05T02:12:52.335Z" "+%m/%d %H:%M"
convert-iso-date() {
  local timestamp="$1"
  local format="${2:-+%m/%d %H:%M}"
  
  # WSL/Linux: date -d で処理
  if date -d "$timestamp" "$format" 2>/dev/null; then
    return 0
  fi
  
  # macOS: date -j -f で処理
  # ISO 8601形式の秒以下を削除してから処理
  if date -j -f "%Y-%m-%dT%H:%M:%S" "${timestamp%%.*}" "$format" 2>/dev/null; then
    return 0
  fi
  
  # フォールバック: 元の値を返す
  echo "$timestamp"
}

# claude-session-select - Claude会話セッションを選択してsessionIdを返す
claude-session-select() {
  # 引数があればそれを使用、なければpwdを使用
  local TARGET_DIR="${1:-$(pwd)}"
  
  # ユーザーメッセージフィルタをエクスポート
  # exportする理由：fzfの--previewオプション内は別プロセスで実行されるため、
  # 親プロセスの変数を参照できない。exportすることで環境変数として子プロセスでも利用可能になる
  # 注意：この環境変数は関数実行時に設定され、現在のシェルセッションに残る
  #
  # このフィルタはユーザー入力とslash commandを抽出し、不要なシステムメッセージを除外する
  # 
  # フィルタ条件の詳細：
  # 1. type == "user" and .sessionId and .message
  #    - typeがuserで、sessionIdとmessageフィールドが存在するものを選択
  # 
  # 2. isSidechain != true
  #    - Claudeのツール使用時に自動生成されるサイドチェーンメッセージを除外
  # 
  # 3. message.role == "user" and (.message.content | type) == "string"
  #    - message.roleがuserで、contentが文字列型のものを選択
  # 
  # 4. 以下の自動生成メッセージを除外：
  #    - "Caveat:" で始まる警告メッセージ
  #    - "<local-command-stdout>" を含むコマンド出力の自動挿入メッセージ
  #    - "tool_use_id" を含むツール使用に関する自動メッセージ
  #    - "tool_result" を含むツール結果に関する自動メッセージ
  #    - "[Request interrupted" を含むリクエスト中断メッセージ
  # 
  # 注：<command-name>を含むslash commandのログは含める
  export JQ_USER_FILTER='
  select(.type == "user" and .sessionId and .message) |
  select(.isSidechain != true) |
  select(.message.role == "user" and (.message.content | type) == "string") |
  select(.message.content | 
    (startswith("Caveat:") | not) and
    (contains("<local-command-stdout>") | not) and
    (contains("tool_use_id") | not) and
    (contains("tool_result") | not) and
    (contains("[Request interrupted") | not)
  )'
  
  # ディレクトリパスをプロジェクトディレクトリ名に変換（/と.を-に置換）
  local PROJECT_DIR=$(echo "$TARGET_DIR" | sed 's/[\/.]/-/g')
  local PROJECT_PATH="${CLAUDE_PROJECTS_DIR}/$PROJECT_DIR"
  
  # プロジェクトディレクトリが存在しない場合は終了
  if [ ! -d "$PROJECT_PATH" ]; then
    echo "No conversations found for: $TARGET_DIR" >&2
    return 1
  fi
  
  # roleがuserでcontentがstringの実際のユーザー入力のみを抽出
  # 各jsonlファイルから以下の形式でデータを抽出：
  # - timestamp: ISO 8601形式の日時
  # - preview: メッセージ内容の最初の80文字（改行を空白に置換）
  # - sessionId: セッションID
  find "$PROJECT_PATH" -name "*.jsonl" -type f | \
  while read -r file; do
    # jqでJSONLファイルを処理：
    # 1. JQ_USER_FILTERでユーザーメッセージとslash commandを抽出
    # 2. 各メッセージから4つの値を配列に格納：
    #    - .timestamp: メッセージのタイムスタンプ
    #    - .message.content: メッセージ内容を以下の処理で整形
    #      - <command-name>タグがある場合はその内容を抽出して使用
    #      - gsub("[\\n\\r\\\\]"; " "): 改行文字とバックスラッシュを空白に置換
    #      - .[0:50]: 最初の50文字を取得（一覧表示用のプレビュー）
    #    - .sessionId: セッションID
    #    - .gitBranch: ブランチ名（存在しない場合は"-"）
    # 3. @tsvでタブ区切り形式に変換
    jq -r --arg file "$file" '
      '"$JQ_USER_FILTER"' |
      [
        .timestamp,
        (
          if .message.content | contains("<command-name>") then
            .message.content | capture("<command-name>(?<cmd>[^<]+)</command-name>") | .cmd
          else
            .message.content | gsub("[\\n\\r\\\\]"; " ") | .[0:50]
          end
        ),
        .sessionId,
        (.gitBranch // "-")
      ] | 
      @tsv
    ' "$file" 2>/dev/null
  done | \
  # awkで重複するセッションIDを除去（$3がsessionId、最初に出現したものだけを残す）
  awk -F'\t' '!seen[$3]++ {print}' | \
  # タイムスタンプで逆順ソート（最新のものが上に）
  sort -r | \
  while IFS=$'\t' read -r timestamp preview sessionId gitBranch; do
    # セッションIDのファイルが存在するかチェック
    if [ -f "$PROJECT_PATH/${sessionId}.jsonl" ]; then
      # ISO 8601形式の日時をローカルタイムに変換
      local local_time=$(convert-iso-date "$timestamp")
      # ブランチ名を整形
      local branch_display=$(printf "%-8s" "${gitBranch:0:8}")
      printf "%s %s %s\t%s\n" "$local_time" "$branch_display" "$preview" "$sessionId"
    fi
  done | \
  # プレビューウィンドウに選択中のセッションの会話履歴を表示
  # 1. jqでメッセージを抽出し、slash commandの場合はコマンド名を表示
  # 2. whileループでタイムスタンプをdateコマンドでローカルタイムに変換
  # 3. [HH:MM] 形式で時刻を表示し、その後にメッセージ内容を表示
  fzf --delimiter=$'\t' \
    --with-nth=1 \
    --header="Sessions in: $TARGET_DIR" \
    --preview='
      session_id=$(echo {} | cut -f2)
      file="'$PROJECT_PATH'/${session_id}.jsonl"
      if [ -f "$file" ]; then        
        jq -r "
          select(.sessionId == \"$session_id\") |
          $JQ_USER_FILTER |
          .timestamp + \"\\t\" + (
            if .message.content | contains(\"<command-name>\") then
              .message.content | capture(\"<command-name>(?<cmd>[^<]+)</command-name>\") | .cmd
            else
              .message.content | gsub(\"[\\n\\r\\\\\\\\]\"; \" \") | .[0:50]
            end
          )
        " "$file" 2>/dev/null | while IFS=$'"'"'\t'"'"' read -r ts msg; do
          local_time=$(date -d "$ts" "+%H:%M" 2>/dev/null || date -r "$ts" "+%H:%M" 2>/dev/null || echo "$ts")
          echo "[$local_time] $msg"
        done
      fi
    ' \
    --preview-window=right:50%:wrap \
    --bind 'enter:become(echo {2})'
}

# claude-session-resume - claude-session-selectで選択したセッションIDでClaudeをresume起動
claude-session-resume() {
  local session_id
  session_id=$(claude-session-select "$@")
  
  if [[ $? -eq 0 && -n "$session_id" ]]; then
    claude -r "$session_id"
  fi
}

# claude-session-open - claude-session-selectで選択したセッションのjsonlファイルを開く
claude-session-open() {
  local session_id
  local TARGET_DIR="${1:-$(pwd)}"
  local PROJECT_DIR=$(echo "$TARGET_DIR" | sed 's/[\/.]/-/g')
  local PROJECT_PATH="${CLAUDE_PROJECTS_DIR}/$PROJECT_DIR"
  
  session_id=$(claude-session-select "$@")
  
  if [[ $? -eq 0 && -n "$session_id" ]]; then
    local file_path="$PROJECT_PATH/${session_id}.jsonl"
    if [ -f "$file_path" ]; then
      ${EDITOR:-code} "$file_path"
    else
      echo "File not found: $file_path" >&2
      return 1
    fi
  fi
}