# 02. アーキテクチャ

## 全体図
```
┌─────────────────────────────────────────────┐
│  Next.js (App Router) + TypeScript / React   │  ← SmartHR/マネフォのUI構成
└───────────────┬─────────────────────────────┘
                │ REST/JSON
┌───────────────▼─────────────────────────────┐
│  Ruby on Rails (中核ドメイン / モノリス)      │  ← 3社の共通言語
│  - 複式簿記の台帳 (Account/JournalEntry/Line) │
│  - 認証 / マルチテナント / API                │
└──────┬───────────────────────┬───────────────┘
       │ (おまけ)              │ (おまけ)
┌──────▼──────────┐   ┌────────▼──────────────┐
│ Go: 取引取込み   │   │ AI: RAGアドバイザー    │  ← GAの RAG-enhanced LLM
│ (CSV/明細パース)  │   │ (Claude API)          │
└─────────────────┘   └───────────────────────┘
       │
┌──────▼──────────────────────────────────────┐
│ DB: SQLite(学習中) → PostgreSQL(イテレ1で移行) │
│ Docker / Kamal / GitHub Actions(CI) / テスト  │
└─────────────────────────────────────────────┘
```

## 技術選定と理由（4社への適合）
| レイヤ | 採用 | 理由 |
|---|---|---|
| 中核BE | **Ruby on Rails 8.1.3** | マネフォ/SmartHR/GAの共通言語。地力(ドメイン/SQL)を鍛えるのに最適 |
| FE | **Next.js + React + TypeScript** | SmartHR/マネフォのUI構成そのもの |
| 取込み(おまけ) | **Go** | マネフォ/GAの「Rails→Go分割」体験 |
| AI(おまけ) | **RAG + Claude API** | GAの RAG-enhanced LLM に対応 |
| DB | SQLite→**PostgreSQL** | 学習はゼロ設定のSQLite、本番志向でPostgresへ |
| 周辺 | Docker / Kamal / GitHub Actions / Minitest(→RSpec検討) | Rails 8標準 + テスト文化(SmartHR) |

## 現在のRuby/Rails環境
- Ruby 4.0.5（mise管理、`~/.local/share/mise/...`）。システムRubyではない → `gem install` に `sudo` 不要。
- Rails 8.1.3（グローバルは着火剤。プロジェクトは `Gemfile.lock` + `.ruby-version` で再現性を担保）。
- `rails new pfm_app`（DB=SQLite既定）で生成済み。Kamal/Dockerfile/GitHub Actions雛形も同梱。
