# トリアージラベル（Triage labels）

課題の扱いを分類する5つの役割は、次のローカルな `Status:` 値に対応する。

| 役割 | Statusの値 | 意味 |
| --- | --- | --- |
| `needs-triage` | `needs-triage` | 保守担当者による評価が必要 |
| `needs-info` | `needs-info` | 追加情報を待っている |
| `ready-for-agent` | `ready-for-agent` | エージェントが実装に着手できる |
| `ready-for-human` | `ready-for-human` | 人による実装が必要 |
| `wontfix` | `wontfix` | 対応しない |

スキルがトリアージの役割を指定した場合は、この表の `Status:` 値を使う。
