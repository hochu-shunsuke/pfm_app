require "rails_helper"

RSpec.describe JournalEntry, type: :model do
  it "借方と貸方が一致すれば有効" do
    # ① 必要なAccountをここで作る（test DBは空だから）
    account = Account.create!(name: "現金", category: "asset")
    # ② JournalEntry.new + journal_lines.build を2本（借方50000/貸方50000）
    entry = JournalEntry.new
    entry.journal_lines.build(account: account, side: "debit", amount: 50000)
    entry.journal_lines.build(account: account, side: "credit", amount: 50000)
    # ③ expect(entry).to be_valid
    expect(entry).to be_valid
  end

  it "借方と貸方が不一致なら無効" do
    # ① 必要なAccountをここで作る（test DBは空だから）
    account = Account.create!(name: "現金", category: "asset")
    # ② JournalEntry.new + journal_lines.build を2本（借方50000/貸方３0000）
    entry = JournalEntry.new
    entry.journal_lines.build(account: account, side: "debit", amount: 50000)
    entry.journal_lines.build(account: account, side: "credit", amount: 30000)
    # ③ expect(entry).to not_to be_valid
    expect(entry).not_to be_valid
  end
end