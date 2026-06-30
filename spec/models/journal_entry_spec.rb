require "rails_helper"

RSpec.describe JournalEntry, type: :model do
  let(:organization) { Organization.create!(name: "テスト組織") }

  it "借方と貸方が一致すれば有効" do
    # 組織経由で作ると organization_id が自動でセットされる（テナント・スコープ）
    account = organization.accounts.create!(name: "現金", category: "asset")
    entry = organization.journal_entries.build(date: Date.today, description: "テスト")
    entry.journal_lines.build(account: account, side: "debit", amount: 50000)
    entry.journal_lines.build(account: account, side: "credit", amount: 50000)
    expect(entry).to be_valid
  end

  it "借方と貸方が不一致なら無効" do
    account = organization.accounts.create!(name: "現金", category: "asset")
    entry = organization.journal_entries.build(date: Date.today, description: "テスト")
    entry.journal_lines.build(account: account, side: "debit", amount: 50000)
    entry.journal_lines.build(account: account, side: "credit", amount: 30000)
    expect(entry).not_to be_valid
  end
end
