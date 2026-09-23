# いつモックするか

**システム境界（system boundaries）**でだけモックする。

- 外部API（決済、メールなど）
- データベース（ときどき。テストDBを優先する）
- 時刻 / 乱数
- ファイルシステム（ときどき）

モックしない。

- 自分たちのクラス / module（モジュール）
- 内部の協力要素
- 自分たちが制御するもの

## モックしやすさのための設計

システム境界では、モックしやすいinterface（インターフェース）を設計する。

**1. 依存性注入を使う**

外部依存を内部で生成せず、渡す。

```typescript
// モックしやすい
function processPayment(order, paymentClient) {
  return paymentClient.charge(order.total);
}

// モックしにくい
function processPayment(order) {
  const client = new StripeClient(process.env.STRIPE_KEY);
  return client.charge(order.total);
}
```

**2. 汎用fetcherよりSDKスタイルのinterfaceを優先する**

条件分岐を持つ1つの汎用関数ではなく、外部操作ごとに具体的な関数を作る。

```typescript
// GOOD: 各関数を個別にモックできる
const api = {
  getUser: (id) => fetch(`/users/${id}`),
  getOrders: (userId) => fetch(`/users/${userId}/orders`),
  createOrder: (data) => fetch('/orders', { method: 'POST', body: data }),
};

// BAD: モックの中に条件分岐が必要になる
const api = {
  fetch: (endpoint, options) => fetch(endpoint, options),
};
```

SDK方式には次の利点がある。

- 各モックが1つの固有の形を返す
- テストの準備に条件分岐がない
- テストがどのエンドポイントを実行するかを確認しやすい
- エンドポイントごとの型安全性
