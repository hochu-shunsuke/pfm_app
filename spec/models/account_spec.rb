require "rails_helper"

RSpec.describe Account, type: :model do
  # let: 各テストで初めて参照された時に1度だけ生成される（遅延・メモ化）
  let(:organization) { Organization.create!(name: "テスト組織") }

  it "categoryが規定外だと無効" do
    account = Account.new(name: "謎", category: "banana", organization: organization)
    expect(account).not_to be_valid
  end

  it "正しいcategoryなら有効" do
    account = Account.new(name: "現金", category: "asset", organization: organization)
    expect(account).to be_valid
  end
end
