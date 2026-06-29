# 04. ドメイン設計：複式簿記の台帳

イテレーション1で**自分の手で**実装する中核。ここが地力の鍛えどころ。

## モデル構成
```
Account (勘定科目)
  - name      : 科目名（例: 現金, 食費, 給与）
  - category  : 5分類のいずれか (asset/liability/equity/revenue/expense)

JournalEntry (仕訳: 1つの取引)
  - date      : 取引日
  - description : 摘要
  - has_many :journal_lines

JournalLine (仕訳明細: 借方 or 貸方の1行)
  - journal_entry_id
  - account_id
  - side      : debit / credit （借方 / 貸方）
  - amount    : 金額（型は未決: integer(銭) 推奨。下記参照）
```

## 守るべき不変条件（invariant）
1. **貸借一致**: 1つの `JournalEntry` 内で `Σ(借方amount) == Σ(貸方amount)`。崩れたら保存させない。
2. **原子性**: 仕訳の保存は1トランザクション。明細の途中で失敗したら全ロールバック。
3. **残高算出**: 任意の `Account` の残高を、複数仕訳をまたいでSQLで正しく集計できる。

## 完了条件（イテレ1のチェックリスト）
- [ ] 借方・貸方が不一致の仕訳は保存に失敗する
- [ ] 仕訳保存が1トランザクションで、途中失敗で全ロールバックする
- [ ] 「現金」勘定の残高が複数仕訳をまたいで正しく集計される
- [ ] テストが緑

## 設計で向き合う問い（考察ポイント）
- 貸借一致は **アプリ層(Rails validation)** と **DB層(check制約)** どちらで守る？両方？トレードオフは？
- 金額は **integer(最小単位=銭)** か **decimal** か。なぜ **float は禁忌**か（丸め誤差）。
- マルチテナントは今は入れないが、後で足すなら `tenant_id` をどこに置くと楽か。
- `side`(debit/credit) を enum 文字列で持つか、符号付き amount 1列で持つか。

> これらは「正解を写す」のでなく、自分で選んで notes に理由を残すのが目的。
