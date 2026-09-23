# 課題トラッカー: ローカルMarkdown

このリポジトリの課題と仕様は `.scratch/` のMarkdownファイルにある。

## 規約

- 1つの機能につき1ディレクトリ: `.scratch/<feature-slug>/`
- 仕様は `.scratch/<feature-slug>/spec.md`
- 実装課題はチケットごとに `.scratch/<feature-slug>/issues/<NN>-<slug>.md` の1ファイルとし、`01` から番号を付ける。単一の結合チケットファイルを作らない。
- トリアージ状態は各課題ファイルの上部付近に `Status:` 行として記録する（役割の文字列は `triage-labels.md` を参照）。
- コメントと会話履歴は、ファイル末尾の `## Comments` 見出しの下に追記する。

## スキルが「課題トラッカーに公開」と言った場合

`.scratch/<feature-slug>/` の下に新しいファイルを作成する（必要ならディレクトリも作る）。

## スキルが「該当するチケットを取得」と言った場合

参照されたパスのファイルを読む。通常、ユーザーはパスまたは課題番号を直接渡す。

## Wayfinderの操作

`/wayfinder` が使う。**マップ**は、チケットごとに**子**ファイルを1つ持つファイルである。

- **マップ**: `.scratch/<effort>/map.md`（Notes / Decisions-so-far / Fog本文）。
- **子チケット**: `.scratch/<effort>/issues/NN-<slug>.md`。`01` から番号を付け、本文に質問を書く。`Type:` 行にチケット種別（`research`/`prototype`/`grilling`/`task`）を記録し、`Status:` 行に `claimed` / `resolved` を記録する。
- **ブロッキング**: 上部付近の `Blocked by: NN, NN` 行。列挙されたすべてのファイルが `resolved` になると、チケットはブロック解除済みである。
- **着手可能な項目（frontier）**: 開いていて、ブロックされておらず、未確保のチケットを `.scratch/<effort>/issues/` から探す。番号が最初のものを選ぶ。
- **確保**: `Status: claimed` に設定して、作業を始める前に保存する。
- **解決**: `## Answer` 見出しの下に回答を追記し、`Status: resolved` に設定して保存する。その後、マップの `map.md` にあるDecisions-so-farへ、参照条件付きの案内（context pointer。要点＋リンク）を追記する。
