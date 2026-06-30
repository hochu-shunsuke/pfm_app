require "rails_helper"

# request spec: 実際にHTTPリクエストを投げて、ルーティング→コントローラ→レスポンスまでを通しで検証する。
# model specより一段広い「結合テスト」。SmartHR等のテスト文化の中核。
RSpec.describe "Accounts", type: :request do
  let(:org_a) { Organization.create!(name: "会社A") }
  let(:org_b) { Organization.create!(name: "会社B") }

  let(:user_a) do
    org_a.users.create!(
      email_address: "a@example.com",
      password: "pw12345",
      password_confirmation: "pw12345"
    )
  end

  before do
    # 各組織に1つずつ口座を用意（名前で見分ける）
    org_a.accounts.create!(name: "現金A", category: "asset")
    org_b.accounts.create!(name: "現金B", category: "asset")
  end

  it "未ログインだと401 JSONを返す" do
    get accounts_path
    expect(response).to have_http_status(:unauthorized)
    expect(response.parsed_body["error"]).to be_present
  end

  it "ログインすると自組織の口座だけがJSONで返る（他組織は混ざらない）" do
    # POST /session でログイン（cookieにセッションが入る）
    post session_path, params: { email_address: user_a.email_address, password: "pw12345" }

    get accounts_path
    expect(response).to have_http_status(:ok)

    names = response.parsed_body.map { |account| account["name"] }
    expect(names).to include("現金A")       # 自組織は見える
    expect(names).not_to include("現金B")   # ★他組織は見えない＝認可境界が効いている
  end

  it "各口座に残高(balance)を含めて返す" do
    post session_path, params: { email_address: user_a.email_address, password: "pw12345" }

    cash  = org_a.accounts.find_by(name: "現金A")
    sales = org_a.accounts.create!(name: "売上", category: "revenue")
    entry = org_a.journal_entries.build(date: Date.today, description: "入金")
    entry.journal_lines.build(account: cash,  side: "debit",  amount: 50000)
    entry.journal_lines.build(account: sales, side: "credit", amount: 50000)
    entry.save!

    get accounts_path
    cash_json = response.parsed_body.find { |a| a["name"] == "現金A" }
    expect(cash_json["balance"]).to eq(50000) # 借方50000 - 貸方0
  end

  it "勘定種類に応じて残高の符号を補正する(資産は借方+, 収益は貸方+)" do
    post session_path, params: { email_address: user_a.email_address, password: "pw12345" }

    cash  = org_a.accounts.find_by(name: "現金A")
    sales = org_a.accounts.create!(name: "売上", category: "revenue")
    entry = org_a.journal_entries.build(date: Date.today, description: "売上")
    entry.journal_lines.build(account: cash,  side: "debit",  amount: 80000)
    entry.journal_lines.build(account: sales, side: "credit", amount: 80000)
    entry.save!

    get accounts_path
    cash_json  = response.parsed_body.find { |a| a["name"] == "現金A" }
    sales_json = response.parsed_body.find { |a| a["name"] == "売上" }
    expect(cash_json["balance"]).to eq(80000)  # 資産: 借方80000 → +80000
    expect(sales_json["balance"]).to eq(80000) # 収益: 貸方80000 → +80000(符号反転)
  end

  describe "POST /accounts" do
    before do
      # 各テストの前にログインしておく
      post session_path, params: { email_address: user_a.email_address, password: "pw12345" }
    end

    it "ログイン中なら自組織に口座を作成できる" do
      expect {
        post accounts_path, params: { account: { name: "普通預金", category: "asset" } }
      }.to change { org_a.accounts.count }.by(1)

      expect(response).to have_http_status(:created)
      expect(org_a.accounts.last.name).to eq("普通預金")
    end

    it "不正なcategoryなら422とエラーを返す" do
      post accounts_path, params: { account: { name: "謎", category: "banana" } }

      expect(response).to have_http_status(:unprocessable_content)
      expect(response.parsed_body["errors"]).to be_present
    end

    it "organization_idをパラメータで渡しても無視され、自組織に作られる" do
      post accounts_path, params: { account: { name: "侵入", category: "asset", organization_id: org_b.id } }

      expect(response).to have_http_status(:created)
      expect(org_a.accounts.last.name).to eq("侵入")            # ログインユーザーのorg_aに作られた
      expect(org_b.accounts.pluck(:name)).not_to include("侵入") # org_bには作られていない
    end
  end
end
