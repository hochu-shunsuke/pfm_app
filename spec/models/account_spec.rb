require "rails_helper"

RSpec.describe Account, type: :model do
  it "categoryが規定外だと無効" do
    account = Account.new(name: "謎", category: "banana")
    expect(account).not_to be_valid
  end

  it "正しいcategoryなら有効" do
    account = Account.new(name: "現金", category: "asset")
    expect(account).to be_valid
  end
end