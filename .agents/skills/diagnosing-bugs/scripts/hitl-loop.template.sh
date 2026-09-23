#!/usr/bin/env bash
# 人が参加する再現手順（human-in-the-loop reproduction loop）。
# このファイルをコピーし、以下の手順を編集して実行する。
# エージェントがスクリプトを実行し、ユーザーは端末に表示される案内に従う。
#
# 使い方：
#   bash hitl-loop.template.sh
#
# 2つの補助関数：
#   step "<instruction>"          → 指示を表示し、Enterを待つ
#   capture VAR "<question>"      → 質問を表示し、回答をVARに読み込む
#
# 最後に、取得した値をエージェントが解析できるKEY=VALUE形式で表示する。
#
# `capture` は値を端末に表示し、エージェントはそこで値を読む。
# そのため、観察した内容を取得し、サインインは `step` としてユーザーに任せる。

set -euo pipefail

step() {
  printf '\n>>> %s\n' "$1"
  read -r -p "    [Enter when done] " _
}

capture() {
  local var="$1" question="$2" answer
  printf '\n>>> %s\n' "$question"
  read -r -p "    > " answer
  printf -v "$var" '%s' "$answer"
}

# --- 以下を編集 ---------------------------------------------------------

step "Open the app at http://localhost:3000 and sign in."

capture ERRORED "Click the 'Export' button. Did it throw an error? (y/n)"

capture ERROR_MSG "Paste the error message (or 'none'):"

# --- ここまでを編集 ---------------------------------------------------------

printf '\n--- Captured ---\n'
printf 'ERRORED=%s\n' "$ERRORED"
printf 'ERROR_MSG=%s\n' "$ERROR_MSG"
