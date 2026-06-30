# 学びログ（イテレ1〜3 + 最適化）

手を動かして詰まりながら得た要点。次に同種の設計に出会った時の引き出し。

## ドメイン / DB
- **多層防御**: アプリ層`validates`(優しい文言・UX)とDB層`null:false`/check制約(最終保証)は冗長でなく役割分担。アプリ層は`validate(:method)`で複数レコードをまたぐ検証も書ける（貸借一致）。
- **複数レコードをまたぐ検証**: 「行ごと」でなく「親(JournalEntry)に集約し、塊をsaveする瞬間に一括検証」。`build`でメモリに積む→`save`で検証＋1トランザクション。`create!`(即保存)だと親の検証は走らない。
- **メモリ集計 vs DB集計**: 保存前の検証は`select{}.sum{}`(メモリ/未保存のbuild行が見える)、保存済みの集計は`where().sum(:col)`(DB側計算)。場面で使い分け。
- **お金は整数×100(1/100円)**: floatは丸め誤差で禁忌。入出力で必ず×100/÷100を一貫。
- **マイグレーション順序**: ファイル名のタイムスタンプ順に実行。参照先テーブルはFKより前に作る必要。順序がずれたらファイル名をリネームして直す(クラス名は独立)。
- **既に適用済みのマイグレーションは編集しない**。新しいマイグレーションを足す。NOT NULLなFKを既存データに足すのは「①nullable追加 ②埋める ③null:false化」の3段階(練習中はdb:dropで回避)。
- **必須の関連を足すと既存テストが壊れる**: `belongs_to`(必須)追加で、それを知らないテストがRecordInvalidに。テストも追従させる(`let`で前提データを共通化)。
- **勘定の残高符号**: 残高=借方-貸方。資産/費用は借方が増(そのまま)、負債/純資産/収益は貸方が増(符号反転)。`debit_normal?`で分岐。

## 認証 / マルチテナント
- **has_secure_password**: 平文は保存せず`password_digest`にbcryptハッシュ。`authenticate(平文)`はgem(activemodel)が動的生成→grep不可。`obj.method(:名前).source_location`で在処を特定、`bundle open gem名`で中身を読む。
- **テナント隔離 = 認可境界**: `Account.all`でなく必ず`Current.user.organization.accounts`経由で辿る。他組織IDを直打ちされても候補に入らない(IDOR対策)。
- **作成時のテナントはセッションから導出**: `organization_id`をパラメータで受け取らない。strong paramsで意図的に除外。明細の`account_id`も`organization.accounts.find_by`で自組織に限定。
- **CurrentAttributes**: 1リクエストの間だけ`Current.user`等を保持し、リクエスト毎にリセット→他リクエストに漏れない。

## API / フロント接続
- **request spec**: ルーティング→認証→コントローラ→JSONまで通しの結合テスト。ログイン(POST /session)してからエンドポイントを叩き、隔離や検証を実証。
- **401 JSON**: API用基底`ApiController`で`request_authentication`を上書き(継承でサブクラス優先)。HTML系はリダイレクトのまま分岐。
- **クロスオリジンSPA認証**: Next(:3001)→Rails(:3000)は別オリジン。CORS(`rack-cors`, credentials:true, 明示オリジン)＋`fetch(credentials:"include")`＋同一サイトcookie。cookieはポートでなくドメイン単位。
- **CSRF**: JSON APIはCORS許可リスト＋SameSite cookieで守り、フォーム用CSRFトークン検証は`skip_forgery_protection`。test環境は元々CSRF無効なのでrspecでは気づけない→dev/本番で表面化。
- **多層防御(UI版)**: フォームでも貸借合計をリアルタイム検証し送信ボタンを無効化(親切)。ただしサーバ検証も生きてる(迂回されても帳簿は壊れない)。

## パフォーマンス
- **N+1**: 一覧で各行ごとに追加クエリ(口座N件×借方/貸方=2N本)。`group(:account_id, :side).sum(:amount)`で1クエリにまとめ、Rubyで集計。dev.logのクエリ数で観察できる。

## 運用Tips
- サーバが起動しない時は`tmp/pids/server.pid`の残骸を疑う(`rm`で復旧)。
