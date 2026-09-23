# 深化

依存関係（dependencies）を踏まえて、shallow module（浅いモジュール）の集合を安全にdeepeningする方法。 [SKILL.md](SKILL.md) の語彙、すなわち **module（モジュール）**、**interface（インターフェース）**、**seam（継ぎ目）**、**adapter（アダプター）** を前提とする。

## 依存関係の分類

deepening候補を評価するときは、その依存関係を分類する。分類によって、deepened moduleをそのseam越しにどうテストするかが決まる。

### 1. In-process（プロセス内）

純粋な計算、メモリ内の状態、I/O（入出力）がないもの。常にdeepenable（深められる）。moduleを統合し、新しいinterfaceを直接通してテストする。adapterは不要。

### 2. Local-substitutable（ローカルで代替可能）

ローカルのテスト用代替物（PGLiteによるPostgres、メモリ内ファイルシステム）がある依存関係。代替物が存在するならdeepeningできる。テストスイートの中で代替物を動かし、deepened moduleをテストする。seamは内部にあり、moduleの外部interfaceにはポートがない。

### 3. Remote but owned（所有するリモート依存、Ports & Adapters）

ネットワークをまたぐ、自分たちが所有するサービス（マイクロサービス、内部API）。seamに **port（ポート）** を定義する。deep module（深いモジュール）がロジックを所有し、トランスポートは **adapter** として注入する。テストではメモリ内adapterを使う。プロダクションではHTTP/gRPC/キューのadapterを使う。

推奨する形: *「seamにportを定義し、プロダクション用のHTTP adapterとテスト用のメモリ内adapterを実装する。そうすれば、ネットワークをまたいでデプロイされても、ロジックは1つのdeep moduleに置ける。」*

### 4. True external（真の外部、Mock）

自分たちが制御しないサードパーティサービス（Stripe、Twilioなど）。deepened moduleは外部依存を注入されたportとして受け取り、テストではmock adapterを渡す。

## Seamの規律

- **adapterが1つなら仮のseam。2つなら本物のseam。** 少なくとも2つのadapterが正当化されるまで、portを導入しない（通常はプロダクション用とテスト用）。adapterが1つだけのseamは単なる間接化である。
- **内部のseamと外部のseam。** deep moduleには、implementation（実装）に閉じた内部のseam（自分のテストが使うもの）と、interfaceにある外部のseamの両方を置ける。テストが使うからといって、内部のseamをinterfaceに公開しない。

## テスト戦略: 重ねずに差し替える

- deepened moduleのinterfaceでテストできるようになったら、shallow module（浅いモジュール）にあった古い単体テストは不要になる。削除する。
- deepened moduleのinterfaceで新しいテストを書く。**interfaceがテストの対象面である。**
- テストは内部状態ではなく、interfaceを通じて観測できる結果を検証する。
- テストは、実装内部をリファクタリングしても維持できるべきである。テストは実装ではなく振る舞いを記述するからである。実装を変えるとテストも変えなければならないなら、そのテストはinterfaceの先をテストしている。
