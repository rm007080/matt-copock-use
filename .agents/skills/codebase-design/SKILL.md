---
name: codebase-design
description: deep module（深いモジュール）を設計するための共有語彙。ユーザーがmoduleのinterface（インターフェース）を設計・改善したい、deepening（深化）の機会を見つけたい、seam（継ぎ目）の場所を決めたい、コードをテストしやすく・AIが案内しやすくしたい場合、または別のスキルがdeep moduleの語彙を必要とする場合に使う。
---

# Codebase Design

小さなinterfaceの背後に多くの振る舞いを置き、明確なseamに配置し、そのinterfaceを通してテストできる **deep module** を設計する。この言葉と原則を、コードを設計・再構成するときは常に使う。目的は、呼び出し元にとってのleverage、保守担当者にとってのlocality、全員にとってのテスト容易性である。

## 用語集

以下の用語を正確に使う。「component」「service」「API」「boundary」に置き換えない。一貫した言葉を使うことが、この用語集の目的である。

**Module（モジュール）**: interfaceとimplementationを持つあらゆるもの。意図的に規模を限定しない。関数、クラス、パッケージ、複数の層にまたがるsliceなどを含む。_避ける_: unit、component、service。

**Interface（インターフェース）**: moduleを正しく使うために呼び出し元が知る必要のあるすべてのこと。型シグネチャだけでなく、不変条件、順序の制約、エラーモード、必須設定、性能特性も含む。_避ける_: API、signature（狭すぎる。型レベルの表面だけを指す）。

**Implementation（実装）**: moduleの内部、つまりコード本体。**Adapter**とは異なる。小さなadapterで大きなimplementation（Postgresリポジトリ）を持つものもあれば、大きなadapterで小さなimplementation（メモリ内のfake）を持つものもある。seamが話題なら「adapter」、それ以外なら「implementation」を使う。

**Depth（深さ）**: interfaceにおけるleverage。呼び出し元（またはテスト）が、学ばなければならないinterfaceの量あたりに実行できる振る舞いの量。小さなinterfaceの背後に多くの振る舞いがあるmoduleを **deep** といい、interfaceがimplementationとほぼ同じ複雑さのmoduleを **shallow（浅い）** という。

**Seam（継ぎ目）**（Michael Feathers）: その場所を編集せずに振る舞いを変更できる場所。moduleのinterfaceが存在する位置でもある。seamをどこに置くかは、背後に何を置くかとは別の設計判断である。_避ける_: boundary（DDDのbounded contextと意味が重なる）。

**Adapter（アダプター）**: seamにあるinterfaceを満たす具体的なもの。中身ではなく、役割（どのスロットを埋めるか）を表す。

**Leverage（てこ）**: depthによって呼び出し元が得るもの。学ぶinterfaceの単位あたりの能力が増える。1つのimplementationがN個の呼び出し箇所とM個のテストで効果を返す。

**Locality（局所性）**: depthによって保守担当者が得るもの。変更、バグ、知識、検証が呼び出し元へ広がらず1か所に集まる。1度直せば、すべてが直る。

## Deepとshallow

**Deep module** = 小さなinterface + 多くのimplementation:

```
┌─────────────────────┐
│   小さなinterface    │  ← メソッドが少なく、単純なパラメーター
├─────────────────────┤
│                     │
│  deep implementation │  ← 複雑なロジックを隠す
│                     │
└─────────────────────┘
```

**Shallow module** = 大きなinterface + 少ないimplementation（避ける）:

```
┌─────────────────────────────────┐
│       大きなinterface             │  ← メソッドが多く、複雑なパラメーター
├─────────────────────────────────┤
│  薄いimplementation               │  ← そのまま通すだけ
└─────────────────────────────────┘
```

interfaceを設計するときは、次を問う。

- メソッドの数を減らせるか。
- パラメーターを単純化できるか。
- より多くの複雑さを内部に隠せるか。

## 原則

- **Depthはimplementationではなくinterfaceの性質である。** deep moduleは、内部に小さくmock可能で交換可能な部品を組み合わせていてもよい。それらはinterfaceの一部ではない。moduleには、implementationに閉じた内部のseam（自分のテストが使うもの）と、interfaceにある外部のseamの両方を置ける。
- **削除テスト。** moduleを削除したと想像する。複雑さが消えるなら、それは単なる通過処理だった。複雑さがN個の呼び出し元に再び現れるなら、それは役割を果たしていた。
- **interfaceがテストの対象面である。** 呼び出し元とテストは同じseamを通る。interfaceの先までテストしたいなら、そのmoduleはおそらく形が間違っている。
- **adapterが1つなら仮のseam。2つなら本物のseam。** そのseamをまたいで実際に変化するものがない限り、seamを導入しない。

## テストしやすさのための設計

良いinterfaceはテストを自然にする。

1. **依存関係を受け取り、生成しない。**

   ```typescript
   // テストしやすい
   function processOrder(order, paymentGateway) {}

   // テストしにくい
   function processOrder(order) {
     const gateway = new StripeGateway();
   }
   ```

2. **副作用を発生させず、結果を返す。**

   ```typescript
   // テストしやすい
   function calculateDiscount(cart): Discount {}

   // テストしにくい
   function applyDiscount(cart): void {
     cart.total -= discount;
   }
   ```

3. **表面積を小さくする。** メソッドが少なければ必要なテストも少ない。パラメーターが少なければテストの準備も単純になる。

## 関係

- 1つの **Module** は、呼び出し元とテストに提示する表面である1つの **Interface** を持つ。
- **Depth** は **Module** の性質であり、その **Interface** に対して測定する。
- **Seam** は **Module** の **Interface** が存在する場所である。
- **Adapter** は **Seam** に置かれ、**Interface** を満たす。
- **Depth** は呼び出し元に **Leverage** を、保守担当者に **Locality** を生む。

## 却下した捉え方

- **Depthをimplementationの行数とinterfaceの行数の比率とすること**（Ousterhout）: implementationに水増しを促す。ここではdepthをleverageとして扱う。
- **「Interface」をTypeScriptの `interface` キーワードやクラスのpublicメソッドとすること**: 狭すぎる。ここでのinterfaceには、呼び出し元が知る必要のあるすべての事実が含まれる。
- **「Boundary」**: DDDのbounded contextと意味が重なる。**seam** または **interface** と言う。

## さらに深める

- **依存関係を踏まえて集合を深める**場合は、[DEEPENING.md](DEEPENING.md) を参照する。依存関係の分類、seamの規律、重ねずに差し替えるテストを扱う。
- **別のinterfaceを検討する**場合は、[DESIGN-IT-TWICE.md](DESIGN-IT-TWICE.md) を参照する。並列サブエージェントを起動してinterfaceを複数の大きく異なる方法で設計し、depth、locality、seamの配置で比較する。
