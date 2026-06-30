# 03. ロードマップ

Web開発(Rails+Next.js)が主役。Go/RAG/インフラは「おまけ最終章」。

| # | 内容 | 鍛える地力 | AI縛り | 状態 |
|---|---|---|---|---|
| **0** | Rails手慣らし（rails new / generate model / db:migrate / console で極小CRUD） | コマンド・リクエストサイクルの体得 | コマンドは教わってよい、コードは手打ち | ✅完了 |
| 1 | 複式簿記の台帳コア（Railsのみ・UIなし） | ドメインモデル, 不変条件, DBトランザクション, SQL集計, テスト | **全部手打ち**。AIは環境構築のみ | ✅完了(RSpec 4 examples緑) |
| 2 | 認証 + REST API + マルチテナント（下にサブ分解） | 認可境界, API設計, tenant分離 | 手打ち中心 | 進行中 |

### イテレ2のサブステップ
| サブ | 内容 | 状態 |
|---|---|---|
| 2-0 | PostgreSQL移行（dev/test=Docker postgres:16、production=Supabase予定）。compose.yaml + database.yml(ENV化) | ✅完了(rspec 4緑のままパリティ確認) |
| 2-1 | ユーザー認証（Rails 8標準の認証ジェネレータ） | 未 |
| 2-2 | マルチテナント（Organization導入、tenant_idでデータ隔離、認可境界） | 未 |
| 2-3 | REST API（accounts/journal_entriesをJSON公開、controller/routes/strong params） | 未 |

DB構成: dev/test=ローカルDocker(`compose.yaml`, user=pfm/pass=pfm_password)、本番=Supabase無料枠（デプロイ章でENV上書き接続）。接続情報はdatabase.ymlで`ENV.fetch(...,デフォルト)`化済み。
| 3 | Next.js/TS でUI（残高・仕訳画面） | 型, コンポーネント設計, 状態管理 | UI骨組みのみAI可 | 未 |
| — | (おまけ) Go取込みサービス / RAGアドバイザー / Docker→AWS/CI | サービス分割・AI・本番化 | 設計は手、実装ペア可 | 未 |

## 未決事項（決めたらこの表を更新）
- **テストフレームワーク**: 現状Minitest(Rails標準, `test/`)。4社はRSpecが主流 → イテレ1の頭で「Minitest継続 or RSpec導入」を決める。
- **DB移行タイミング**: SQLite → PostgreSQL はイテレ1の頭（データを入れる前）に実施予定。
- **金額の型**: integer(最小単位=銭) か decimal か。float禁忌の理由とともにイテレ1で決定。
- **マルチテナント方式**: `tenant_id`列 / スキーマ分離 / DB分離。イテレ2で決定。

## イテレーション後にやること
`docs/notes/iter-NN-*.md` に「設計判断 / 詰まった点 / 次にやること」を3行ずつ残す。
