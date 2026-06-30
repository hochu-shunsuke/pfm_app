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

  it "未ログインだとログイン画面にリダイレクトされる" do
    get accounts_path
    expect(response).to redirect_to(new_session_path)
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
