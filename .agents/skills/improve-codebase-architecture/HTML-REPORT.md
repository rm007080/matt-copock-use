# HTMLレポートの形式

アーキテクチャレビューは、OSの一時ディレクトリにある単一の自己完結型HTMLファイルとして描画する。TailwindとMermaidはどちらもCDNから読み込む。Mermaidはグラフ形状の図を確実に扱う。手作りのdivとインラインSVGは、より編集的なビジュアル（質量図、断面図）に使う。両方を組み合わせる。すべてをMermaidに頼ると、見た目が一般的になり始める。

## 骨組み

```html
<!doctype html>
<html lang="en">
  <head>
    <meta charset="utf-8" />
    <title>Architecture review for {{repo name}}</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <script type="module">
      import mermaid from "https://cdn.jsdelivr.net/npm/mermaid@11/dist/mermaid.esm.min.mjs";
      mermaid.initialize({ startOnLoad: true, theme: "neutral", securityLevel: "loose" });
    </script>
    <style>
      /* Tailwindがきれいに対応できないもののための小さなカスタム層:
         破線のseam（継ぎ目）、手描き風の矢印の先端など */
      .seam { stroke-dasharray: 4 4; }
      .leak { stroke: #dc2626; }
      .deep { background: linear-gradient(135deg, #0f172a, #1e293b); }
    </style>
  </head>
  <body class="bg-stone-50 text-slate-900 font-sans">
    <main class="max-w-5xl mx-auto px-6 py-12 space-y-12">
      <header>...</header>
      <section id="candidates" class="space-y-10">...</section>
      <section id="top-recommendation">...</section>
    </main>
  </body>
</html>
```

## ヘッダー

ヘッダーには、リポジトリ名、日付、簡潔な凡例を置く。実線の箱 = module（モジュール）、破線 = seam（継ぎ目）、赤い矢印 = 漏れ、太い暗色の箱 = deep module（深いモジュール）。導入段落は置かない。候補から直接始める。

## 候補カード

図が中心となる。文章はまばらで平易にし、`/codebase-design` スキルの用語集の語を飾らずに使う。

各候補は1つの `<article>` とする。

- **タイトル**: 短くし、深化の内容を名指しする（例: 「Orderの取り込みパイプラインを統合する」）。
- **バッジ行**: 推奨の強さ（`Strong` = emerald、`Worth exploring` = amber、`Speculative` = slate）と、依存関係の分類（`in-process`、`local-substitutable`、`ports & adapters`、`mock`）のタグ。
- **ファイル**: 等幅フォントの一覧、`font-mono text-sm`。
- **変更前 / 変更後の図**: 中心となるもの。2列を横に並べる。以下のパターンを参照。
- **問題**: 1文。何が痛いのか。
- **解決策**: 1文。何が変わるのか。
- **改善効果**: 箇条書き、各項目は6語以下。例: 「1つのinterfaceをテストする」「Pricingのロジックの漏れを止める」「4つのshallow wrapperを削除する」。
- **ADRの注記**（該当する場合）: 琥珀色の背景の箱に1行。

説明の段落は置かない。図を理解するのに段落が必要なら、図を描き直す。

## 図のパターン

候補に合うパターンを選ぶ。組み合わせる。すべての図を同じ見た目にしない。多様性も目的の一部である。

### Mermaidグラフ（依存関係 / 呼び出しフローの主力）

「XがYを呼び、YがZを呼ぶ。この混乱を見よ」という点には、Mermaidの `flowchart` または `graph` を使う。Tailwindでスタイルを付けたカードで包み、突然置かれた印象をなくす。`classDef` で漏れのエッジを赤く、deep moduleを暗くする。シーケンス図は「変更前: 6往復、変更後: 1往復」に適している。

```html
<div class="rounded-lg border border-slate-200 bg-white p-4">
  <pre class="mermaid">
    flowchart LR
      A[OrderHandler] --> B[OrderValidator]
      B --> C[OrderRepo]
      C -.leak.-> D[PricingClient]
      classDef leak stroke:#dc2626,stroke-width:2px;
      class C,D leak
  </pre>
</div>
```

### 手作りの箱と矢印（Mermaidのレイアウトが合わない場合）

moduleを境界線とラベル付きの `<div>` として描く。矢印には、相対コンテナーの上に絶対配置するインラインSVGの `<line>` または `<path>` 要素を使う。「変更後」の図を、灰色になった内部を持つ、太い枠線の1つのdeep moduleにしたい場合に使う。Mermaidでは正しい太さで描画できないためである。

### 断面図（層状の浅さに適する）

水平な帯（`h-12 border-l-4`）を積み重ね、呼び出しが通る層を示す。変更前: 何もしていない薄い層が6つ。変更後: 統合された責務をラベル付けした厚い帯が1つ。

### 質量図（「interfaceがimplementationと同じ幅」に適する）

moduleごとに長方形を2つ置く。1つはinterfaceの表面積、もう1つはimplementation（実装）を表す。変更前: interfaceの長方形がimplementationの長方形とほぼ同じ高さ（shallow（浅い））。変更後: interfaceの長方形は短く、implementationの長方形は高い（deep）。

### 呼び出しグラフの統合

変更前: 関数呼び出しの木を入れ子の箱として描画する。変更後: 同じ木を1つの箱に統合し、今や内部になった呼び出しを薄く表示する。

## スタイルの指針

- 企業向けダッシュボードではなく、編集的で簡潔な見た目にする。余白を十分に取る。見出しにはserif（`font-serif`）を使ってもよい。
- 色は控えめにする。アクセントは1色（emeraldまたはindigo）とし、漏れには赤、警告には琥珀色を使う。
- 図の高さはおよそ320pxに保ち、変更前 / 変更後をスクロールせず横に置けるようにする。
- 図の中のmoduleラベルには `text-xs uppercase tracking-wider` を使い、UIではなく模式図として読めるようにする。
- スクリプトはTailwindのCDNとMermaidのESM importだけにする。レポートはそれ以外は静的で、Mermaid自身の描画を除けばアプリコードもインタラクションもない。

## 最上位の推奨セクション

より大きなカードを1つ置く。候補名、理由を述べる1文、その候補カードへのアンカーリンクだけを含める。

## トーン

平易で簡潔な英語にする。ただし、アーキテクチャ上の名詞と動詞は `/codebase-design` スキルから直接取る。簡潔さを理由に言葉をずらさない。

**必ず使う:** module（モジュール）, interface（インターフェース）, implementation（実装）, depth（深さ）, deep（深い）, shallow（浅い）, seam（継ぎ目）, adapter（アダプター）, leverage（てこ）, locality（局所性）。

**決して置き換えない:** component, service, unit（moduleの意味で） · API, signature（interfaceの意味で） · boundary（seamの意味で） · layer, wrapper（moduleの意味で使う場合）。

**このスタイルに合う言い回し:**

- 「Order intake moduleはshallowで、interfaceがimplementationとほぼ同じである。」
- 「Pricingはseamをまたいで漏れる。」
- 「深める: 1つのinterface、1つのテスト場所。」
- 「2つのadapterがseamを正当化する: 本番はHTTP、テストはメモリ内。」

改善効果の箇条書きでは、用語集の語で得られるものを名指しする。*「locality: バグが1つのmoduleに集まる」*、*「leverage: 1つのinterface、N個の呼び出し箇所」*、*「interfaceが縮み、implementationがwrapperを吸収する」* のように書く。「保守しやすい」や「きれいなコード」とは書かない。それらの語は用語集にないため、使う理由がない。

婉曲表現、前置き、「注目すべき点として…」を使わない。文が箇条書きにできるなら、箇条書きにする。箇条書きを削れるなら削る。語が `/codebase-design` の用語集にないなら、新しい語を作る前に用語集の語を使う。
