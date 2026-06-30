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
| 2-1 | ユーザー認証（Rails 8標準）生成・migrate済。※user_specは未記入(pending) | ✅おおむね完了 |
| 2-2 | マルチテナント（Organization導入、organization_idで隔離、belongs_to/has_many配線、認可境界の土台） | ✅完了(rspec緑) |
| 2-3 | REST API（accounts/journal_entriesをJSON公開、controller/routes/strong params） | ✅完了 |

#### 2-3 の内訳
- ✅ GET /accounts（一覧・組織スコープ）
- ✅ POST /accounts（作成・組織はセッション導出・strong paramsでorganization_id除外）
- ✅ POST /journal_entries（複数明細を一括・各行account_idも自組織限定・貸借検証・トランザクション）
- ✅ API用401 JSON対応（ApiController基底でrequest_authenticationを上書き）
- request spec計: accounts 5 + journal_entries 3。全体16 examples 0 failures。
- コミット: 98e4d6d(accounts create) / 6d90448(journal_entries create) / c62f7a1(401 JSON)
- ⬜ 残課題(イテレ3で対応): NextとRailsを繋ぐ際のCSRF/cookie or トークン方針、journal_entriesのindex等

DB構成: dev/test=ローカルDocker(`compose.yaml`, user=pfm/pass=pfm_password)、本番=Supabase無料枠（デプロイ章でENV上書き接続）。接続情報はdatabase.ymlで`ENV.fetch(...,デフォルト)`化済み。
| 3 | Next.js/TS でUI（残高・仕訳画面） | 型, コンポーネント設計, 状態管理 | UI骨組みのみAI可 | 🔵進行中 |

### イテレ3のサブステップ
| サブ | 内容 | 状態 |
|---|---|---|
| 3-1a | Next生成(frontend/, Next16/TS/App Router/Tailwind)＋CORS＋ポート3001＋API URL。疎通確認済 | ✅完了 |
| 3-1b | ログインフォーム(POST /session,JSON)＋cookie認証で口座一覧取得。Rails側SPA対応(JSONログイン/CSRFスキップ)済 | ✅完了 |
| 3-2 | 残高ダッシュボード(口座一覧＋balance)。API GET /accountsにbalance付与、画面に¥表示 | ✅完了 |
| 3-3 | 仕訳入力フォーム(行を動的増減＋クライアント側貸借チェック) | 🔵進行中 |

未対応メモ: 収益/負債の残高符号(category別の反転)。N+1(balanceが口座ごと2クエリ)。
| 3-4 | ローディング/エラー処理 | 未 |

構成: pfm_app/直下=Rails(:3000)、pfm_app/frontend/=Next(:3001)。認証は同一サイトcookie。
注意: このNextは**Next 16**でbreaking changesあり。frontend/AGENTS.mdの指示通り、UIコードを書く前に node_modules/next/dist/docs/ の該当ガイドを確認する。
| — | (おまけ) Go取込みサービス / RAGアドバイザー / Docker→AWS/CI | サービス分割・AI・本番化 | 設計は手、実装ペア可 | 未 |

## 未決事項（決めたらこの表を更新）
- **テストフレームワーク**: 現状Minitest(Rails標準, `test/`)。4社はRSpecが主流 → イテレ1の頭で「Minitest継続 or RSpec導入」を決める。
- **DB移行タイミング**: SQLite → PostgreSQL はイテレ1の頭（データを入れる前）に実施予定。
- **金額の型**: integer(最小単位=銭) か decimal か。float禁忌の理由とともにイテレ1で決定。
- **マルチテナント方式**: `tenant_id`列 / スキーマ分離 / DB分離。イテレ2で決定。

## イテレーション後にやること
`docs/notes/iter-NN-*.md` に「設計判断 / 詰まった点 / 次にやること」を3行ずつ残す。
