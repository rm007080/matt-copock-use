# 課題管理（Issue tracker）：ローカルMarkdown

このリポジトリの課題（issue）と仕様書（spec）は、`.scratch/` 内のMarkdownファイルで管理する。

## 規約

- 機能ごとに1つのディレクトリを使う：`.scratch/<feature-slug>/`。
- 仕様書は `.scratch/<feature-slug>/spec.md` に置く。
- 実装課題は、チケット（ticket）ごとに `.scratch/<feature-slug>/issues/<NN>-<slug>.md` に1ファイルを置き、依存順に `01` から番号を付ける。チケットのファイルは、番号プレフィックスを禁止する命名規則の合意済みの例外とする。
- トリアージ（triage）の状態は、各課題ファイルの先頭近くにある `Status:` 行で表す。`docs/agents/triage-labels.md` の名前を使う。
- 会話履歴は `## Comments` 見出しの下に追記する。

## スキルが「課題管理先に公開する」と指示したとき

必要に応じてディレクトリを作り、`.scratch/<feature-slug>/` 配下に適切な仕様書または課題ファイルを作成する。

## スキルが「該当するチケットを取得する」と指示したとき

参照された課題ファイルを読む。番号だけでは複数の機能に該当する場合は、機能名を尋ねる。

## Wayfinding operations

作業の道筋を表すマップ（map）は `.scratch/<effort>/map.md` に置く。子チケットはそれぞれ `.scratch/<effort>/issues/<NN>-<slug>.md` に置き、`01` から番号を付ける。

- マップには Notes、Decisions-so-far、Fog を記載する。
- 子チケットの `Type:` 行は `research`、`prototype`、`grilling`、`task` のいずれかとし、`Status:` 行は `claimed` または `resolved` とする。
- `Blocked by: NN, NN` 行には、着手を妨げているチケットの番号を列挙する。すべての依存先が `resolved` になると、そのチケットに着手できる。
- 着手可能な項目（frontier）を見つけるには、未完了で、依存先による妨げがなく、未取得のチケットを調べる。番号が最も小さいものを優先する。
- 担当として取得するには、作業を始める前に `Status: claimed` を設定して保存する。
- 解決するには、`## Answer` 節を追加して `Status: resolved` を設定し、マップの Decisions-so-far へのリンクを付けた要約を追記する。
