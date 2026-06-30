# Next.js フロント(別オリジン)からの API アクセスを許可する。
# credentials: true ＝ cookie を伴うリクエストを許可（セッション認証のため）。
# credentials を許可する場合 origins に "*" は使えず、明示的なオリジン指定が必須。
Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    origins ENV.fetch("FRONTEND_ORIGIN", "http://localhost:3001")

    resource "*",
      headers: :any,
      methods: [:get, :post, :patch, :put, :delete, :options, :head],
      credentials: true
  end
end
