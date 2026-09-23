# 課題トラッカー: GitHub

このリポジトリの課題と仕様はGitHub Issuesにある。すべての操作に `gh` CLIを使う。

## 規約

- **課題を作成**: `gh issue create --title "..." --body "..."`。複数行の本文にはheredocを使う。
- **課題を読む**: `gh issue view <number> --comments`。`jq` でコメントをフィルターし、ラベルも取得する。
- **課題を一覧表示**: `gh issue list --state open --json number,title,body,labels,comments --jq '[.[] | {number, title, body, labels: [.labels[].name], comments: [.comments[].body]}]'`。適切な `--label` と `--state` フィルターを付ける。
- **課題にコメント**: `gh issue comment <number> --body "..."`
- **ラベルを適用 / 削除**: `gh issue edit <number> --add-label "..."` / `--remove-label "..."`
- **閉じる**: `gh issue close <number> --comment "..."`

`git remote -v` からリポジトリを推測する。クローン内で実行すれば `gh` が自動的に行う。

## Pull requestをtriage対象にする場合

**PRs as a request surface: no.** _(このリポジトリが外部PRを機能要望として扱う場合は `yes` にする。`/triage` がこのフラグを読む。)_

`yes` のとき、PRは課題と同じラベルと状態を通り、`gh pr` 相当の操作を使う:

- **PRを読む**: `gh pr view <number> --comments` と `gh pr diff <number>` で差分を読む。
- **triage対象の外部PRを一覧表示**: `gh pr list --state open --json number,title,body,labels,author,authorAssociation,comments` を実行し、`authorAssociation` が `CONTRIBUTOR`、`FIRST_TIME_CONTRIBUTOR`、`NONE` のものだけを残す（`OWNER` / `MEMBER` / `COLLABORATOR` は除外）。
- **コメント / ラベル / クローズ**: `gh pr comment`、`gh pr edit --add-label`/`--remove-label`、`gh pr close`。

GitHubでは課題とPRが同じ番号空間を共有するため、裸の `#42` はどちらか分からない場合がある。`gh pr view 42` で解決し、該当しなければ `gh issue view 42` にフォールバックする。

## スキルが「課題トラッカーに公開」と言った場合

GitHub課題を作成する。

## スキルが「該当するチケットを取得」と言った場合

`gh issue view <number> --comments` を実行する。

## Wayfinderの操作

`/wayfinder` が使う。**マップ**は、チケットとなる**子**課題を持つ単一の課題である。

- **マップ**: `wayfinder:map` ラベルを付けた単一の課題。Notes / Decisions-so-far / Fog本文を持つ。`gh issue create --label wayfinder:map`。
- **子チケット**: GitHubのサブ課題としてマップにリンクされた課題（サブ課題エンドポイントに対する `gh api`）。サブ課題が有効でない場合は、マップ本文のタスクリストに子を追加し、子本文の先頭に `Part of #<map>` を置く。ラベルは `wayfinder:<type>`（`research`/`prototype`/`grilling`/`task`）。確保すると、チケットを進める開発者が担当者になる。
- **ブロッキング**: GitHubの**ネイティブ課題依存関係**が標準でUIに表示される表現である。`gh api --method POST repos/<owner>/<repo>/issues/<child>/dependencies/blocked_by -F issue_id=<blocker-db-id>` で辺を追加する。ここで `<blocker-db-id>` はブロッカーの数値の**データベースID**であり（`gh api repos/<owner>/<repo>/issues/<n> --jq .id`）、`#number` や `node_id` ではない。GitHubは `issue_dependencies_summary.blocked_by`（開いているブロッカーのみ、現在のゲート）を返す。依存関係が使えない場合は、子本文の先頭に `Blocked by: #<n>, #<n>` 行を置く方式にフォールバックする。すべてのブロッカーが閉じると、チケットはブロック解除済みである。
- **着手可能な項目（frontier）のクエリ**: マップの開いている子（マップのサブ課題 / タスクリストに絞った `gh issue list --state open`）を一覧し、開いているブロッカー（`issue_dependencies_summary.blocked_by > 0`、または `Blocked by` 行にある開いた課題）または担当者があるものを除外する。マップ順で最初のものを選ぶ。
- **確保**: `gh issue edit <n> --add-assignee @me`。そのセッションで最初に行う書き込みである。
- **解決**: `gh issue comment <n> --body "<answer>"`、続けて `gh issue close <n>` を実行し、マップのDecisions-so-farに参照条件付きの案内（context pointer。要点＋リンク）を追記する。
