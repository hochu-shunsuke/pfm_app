# pfm_app

複式簿記の台帳を中核にした **PFM（家計簿/資産管理）SaaS + AIアドバイザー**。
主目的は「手を動かす実装スキルの回復」。題材はそのための器。

## 設計ドキュメント
方針・設計は `docs/` に外出ししている。まず [docs/README.md](./docs/README.md)（目次）から。

- [01 概要](./docs/01-overview.md) / [02 アーキテクチャ](./docs/02-architecture.md) / [03 ロードマップ](./docs/03-roadmap.md)
- [04 台帳ドメイン設計](./docs/04-domain-ledger.md) / [05 進め方](./docs/05-how-we-work.md)
- 作業ログ: [docs/notes/](./docs/notes/)

## 開発環境
- Ruby 4.0.5（mise管理） / Rails 8.1.3
- DB: SQLite（学習中。PostgreSQLへ移行予定）

```bash
bin/rails server     # http://localhost:3000
bin/rails console    # 対話コンソール
bin/rails test       # テスト（Minitest）
```
