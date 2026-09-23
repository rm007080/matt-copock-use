# 良いテストと悪いテスト

## 良いテスト

**統合スタイル**: 内部部品のモックではなく、本物のinterface（インターフェース）を通してテストする。

```typescript
// GOOD: 観測可能な振る舞いをテストする
test("user can checkout with valid cart", async () => {
  const cart = createCart();
  cart.add(product);
  const result = await checkout(cart, paymentMethod);
  expect(result.status).toBe("confirmed");
});
```

特徴:

- ユーザー / 呼び出し元が気にする振る舞いをテストする
- public APIだけを使う
- 内部のリファクタリングに耐える
- 方法ではなく、何をするかを記述する
- テストごとに1つの論理的なアサーション

## 悪いテスト

**実装詳細のテスト**: 内部構造に結合している。

```typescript
// BAD: 実装の詳細をテストする
test("checkout calls paymentService.process", async () => {
  const mockPayment = jest.mock(paymentService);
  await checkout(cart, payment);
  expect(mockPayment.process).toHaveBeenCalledWith(cart.total);
});
```

危険信号:

- 内部の協力要素をモックする
- privateメソッドをテストする
- 呼び出し回数 / 順序をアサートする
- 振る舞いが変わっていないのにリファクタリングでテストが壊れる
- テスト名が何をするかではなく、どうするかを記述する
- interfaceではなく外部手段で検証する

```typescript
// BAD: interfaceを迂回して検証する
test("createUser saves to database", async () => {
  await createUser({ name: "Alice" });
  const row = await db.query("SELECT * FROM users WHERE name = ?", ["Alice"]);
  expect(row).toBeDefined();
});

// GOOD: interfaceを通して検証する
test("createUser makes user retrievable", async () => {
  const user = await createUser({ name: "Alice" });
  const retrieved = await getUser(user.id);
  expect(retrieved.name).toBe("Alice");
});
```

**同語反復的なテスト**: 期待値が実装を言い換えているため、構成によって通る。

```typescript
// BAD: 期待値を、コードと同じ方法で再計算する
test("calculateTotal sums line items", () => {
  const items = [{ price: 10 }, { price: 5 }];
  const expected = items.reduce((sum, i) => sum + i.price, 0);
  expect(calculateTotal(items)).toBe(expected);
});

// GOOD: 期待値は独立した既知のリテラル
test("calculateTotal sums line items", () => {
  expect(calculateTotal([{ price: 10 }, { price: 5 }])).toBe(15);
});
```
