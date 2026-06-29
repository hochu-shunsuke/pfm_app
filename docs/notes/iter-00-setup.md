# iter-00: 環境セットアップ

## やったこと
- Ruby 4.0.5（mise管理）/ Rails 8.1.3（グローバル）を確認。
- `rails new pfm_app`（DB=SQLite既定）でプロジェクト生成。
- `bin/rails server` → http://localhost:3000 で初期画面の表示を確認。
- `docs/` に設計を仕分けて外出し（01〜05 + このnotes）。

## 設計判断
- DBは学習中はSQLite。本番志向のPostgres移行はイテレ1の頭（データ投入前）に行う。
- 再現性はグローバルrailsでなく `Gemfile.lock` + `.ruby-version` が担保する、と整理。

## 詰まった点
- `rails` が「未インストール」表示 → macOS標準 `/usr/bin/rails` の囮スタブが原因。mise配下のrubyに `gem install rails`（sudoなし）で解決。

## 次にやること
- 最初のモデル `Account` を `bin/rails generate model` で**自分の手で**作る。
- 生成された model / migration の中身を読んで「何ができたか」を観察。
- イテレ1の頭で「Minitest継続 or RSpec」「DB Postgres移行」「金額の型」を決める。
