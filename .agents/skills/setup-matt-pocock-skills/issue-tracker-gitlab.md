# 課題トラッカー: GitLab

このリポジトリの課題はGitLab Issuesにある。すべての操作に [`glab`](https://gitlab.com/gitlab-org/cli) CLIを使う。

## 全体文書とローカル計画

全体要求の正本は `docs/spec.md`。目標構成は `docs/architecture.md`、採用技術は `docs/tech-stack.md` に置き、`/to-spec` が作成・更新する。これらは外部Issuesへ仕様として投稿しない。

任意の実装計画は `docs/work/YYYY-MM-DD-NN-<work-slug>/<work-slug>-implementation-plan.md` に保存する。セットアップ時に、ローカルひな形の「配置」「作業フォルダーの特定と作成」を出力先の規約へ取り込み、作成日・採番・再利用を定義する。実装課題とWayfinder課題の発行・取得・依存関係は、この文書の外部トラッカー方式を維持する。

## 規約

- **課題を作成**: `glab issue create --title "..." --description "..."`。複数行の説明にはheredocを使う。エディターを開くには `--description -` を渡す。
- **課題を読む**: `glab issue view <number> --comments`。機械可読な出力には `-F json` を使う。
- **課題を一覧表示**: `glab issue list -F json`。適切な `--label` フィルターを付ける。
- **課題にコメント**: `glab issue note <number> --message "..."`。GitLabではコメントを「notes」と呼ぶ。
- **ラベルを適用 / 削除**: `glab issue update <number> --label "..."` / `--unlabel "..."`。複数のラベルはコンマ区切りにするか、フラグを繰り返す。
- **閉じる**: `glab issue close <number>`。`glab issue close` はクローズコメントを受け付けないため、まず `glab issue note <number> --message "..."` で説明を投稿し、その後に閉じる。
- **マージリクエスト**: GitLabではPRを「merge requests」と呼ぶ。`glab mr create`、`glab mr view`、`glab mr note` などを使う。`pr` を `mr` に、`comment` / `--body` を `note` / `--message` に置き換えた `gh pr ...` と同じ形である。

`git remote -v` からリポジトリを推測する。クローン内で実行すれば `glab` が自動的に行う。

## Merge requestをtriage対象にする場合

**MRs as a request surface: no.** _(このリポジトリが外部マージリクエストを機能要望として扱う場合は `yes` にする。`/triage` がこのフラグを読む。)_

`yes` のとき、MRは課題と同じラベルと状態を通り、`glab mr` 相当の操作を使う:

- **MRを読む**: `glab mr view <number> --comments` と `glab mr diff <number>` で差分を読む。
- **triage対象の外部MRを一覧表示**: `glab mr list -F json` を実行し、作成者がプロジェクトのメンバー / オーナーではないMRだけを残す（メンテナーの作業中MRではなく、コントリビューターのMR）。
- **コメント / ラベル / クローズ**: `glab mr note`、`glab mr update --label`/`--unlabel`、`glab mr close`。

GitHubと異なり、GitLabは課題とMRを別々に番号付けするため、メンテナーがどちらの面を指しているか分かれば `#42` は曖昧でない。

## スキルが「課題トラッカーに公開」と言った場合

GitLab課題を作成する。

## スキルが「該当するチケットを取得」と言った場合

`glab issue view <number> --comments` を実行する。

## Wayfinderの操作

`/wayfinder` が使う。**マップ**は、チケットとなる**子**課題を持つ単一の課題である。

- **マップ**: `wayfinder:map` ラベルを付けた単一の課題。Notes / Decisions-so-far / Fog本文を持つ。`glab issue create --label wayfinder:map`。（ネイティブエピックを使えるGitLabプランでも、ラベル付き課題はどこでも使える。）
- **子チケット**: 説明の先頭に `Part of #<map>` を置き、`wayfinder:<type>`（`research`/`prototype`/`grilling`/`task`）ラベルを付けた課題。確保すると、チケットを進める開発者が担当者になる。
- **ブロッキング**: GitLabの**ネイティブブロッキングリンク**が標準でUIに表示される表現である。ノートとして `/blocked_by #<n>` クイックアクションを投稿する（`glab issue note <child> --message "/blocked_by #<blocker>"`）。ネイティブブロッキングリンクはPremium/Ultimateの機能である。無料プランまたは利用できない場合は、説明の先頭に `Blocked by: #<n>, #<n>` 行を置く方式にフォールバックする。すべてのブロッカーが閉じると、チケットはブロック解除済みである。
- **着手可能な項目（frontier）のクエリ**: マップの子に絞った `glab issue list -F json` を使い、開いているブロッカーがあるものを除外する。開いている課題へのネイティブ `blocked_by` リンク（`glab api projects/:id/issues/:iid/links`）、`Blocked by` 行にある開いた課題、または担当者があるものを除外し、マップ順で最初のものを選ぶ。
- **確保**: `glab issue update <n> --assignee @me`。そのセッションで最初に行う書き込みである。
- **解決**: `glab issue note <n> --message "<answer>"`、続けて `glab issue close <n>` を実行し、マップのDecisions-so-farに参照条件付きの案内（context pointer。要点＋リンク）を追記する。
