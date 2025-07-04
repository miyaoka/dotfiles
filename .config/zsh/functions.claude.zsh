# Claude関連の関数

readonly CLAUDE_PROJECTS_DIR="$HOME/.claude/projects"

# claude-session-select - Claude会話セッションを選択してsessionIdを返す
claude-session-select() {
  # 引数があればそれを使用、なければpwdを使用
  local TARGET_DIR="${1:-$(pwd)}"
  
  # ユーザーメッセージフィルタをエクスポート
  # exportする理由：fzfの--previewオプション内は別プロセスで実行されるため、
  # 親プロセスの変数を参照できない。exportすることで環境変数として子プロセスでも利用可能になる
  # 注意：この環境変数は関数実行時に設定され、現在のシェルセッションに残る
  #
  # このフィルタは実際のユーザー入力のみを抽出し、システムメッセージや自動生成されたメッセージを除外する
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
  #    - "<command-name>" を含むコマンド実行の自動挿入メッセージ
  #    - "<local-command-stdout>" を含むコマンド出力の自動挿入メッセージ
  #    - "tool_use_id" を含むツール使用に関する自動メッセージ
  #    - "tool_result" を含むツール結果に関する自動メッセージ
  #    - "[Request interrupted" を含むリクエスト中断メッセージ
  export JQ_USER_FILTER='
  select(.type == "user" and .sessionId and .message) |
  select(.isSidechain != true) |
  select(.message.role == "user" and (.message.content | type) == "string") |
  select(.message.content | 
    (startswith("Caveat:") | not) and
    (contains("<command-name>") | not) and
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
    # 1. JQ_USER_FILTERでユーザーメッセージのみを抽出
    # 2. 各メッセージから3つの値を配列に格納：
    #    - .timestamp: メッセージのタイムスタンプ
    #    - .message.content: メッセージ内容を以下の処理で整形
    #      - gsub("[\\\\\\n\\r]"; " "): バックスラッシュと改行文字を空白に置換
    #      - .[0:50]: 最初の50文字を取得（一覧表示用のプレビュー）
    #    - .sessionId: セッションID
    # 3. @tsvでタブ区切り形式に変換
    jq -r --arg file "$file" '
      '"$JQ_USER_FILTER"' |
      [.timestamp, (.message.content | gsub("[\\\\\\n\\r]"; " ") | .[0:50]), .sessionId] | 
      @tsv
    ' "$file" 2>/dev/null
  done | \
  # awkで重複するセッションIDを除去（$3がsessionId、最初に出現したものだけを残す）
  awk -F'\t' '!seen[$3]++ {print}' | \
  # タイムスタンプで逆順ソート（最新のものが上に）
  sort -r | \
  while IFS=$'\t' read -r timestamp preview sessionId; do
    # セッションIDのファイルが存在するかチェック
    if [ -f "$PROJECT_PATH/${sessionId}.jsonl" ]; then
      # ISO 8601形式の日時をローカルタイムに変換
      local local_time=$(date -d "$timestamp" "+%m/%d %H:%M" 2>/dev/null || date -r "$timestamp" "+%m/%d %H:%M" 2>/dev/null || echo "$timestamp")
      printf "%s  %s\t%s\n" "$local_time" "$preview" "$sessionId"
    fi
  done | \
  # プレビューウィンドウに選択中のセッションの会話履歴を表示
  # 1. jqでメッセージを抽出し、改行を空白に置換して最初の200文字を取得
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
          .timestamp + \"\\t\" + (.message.content | gsub(\"[\\\\\\\\\\\\\\n\\r]\"; \" \") | .[0:50])
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