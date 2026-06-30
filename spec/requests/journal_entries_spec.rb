require "rails_helper"

RSpec.describe "JournalEntries", type: :request do
  let(:org_a) { Organization.create!(name: "会社A") }
  let(:org_b) { Organization.create!(name: "会社B") }
  let(:user_a) do
    org_a.users.create!(email_address: "a@example.com", password: "pw12345", password_confirmation: "pw12345")
  end
  let(:cash) { org_a.accounts.create!(name: "現金", category: "asset") }
  let(:food) { org_a.accounts.create!(name: "食費", category: "expense") }

  before do
    post session_path, params: { email_address: user_a.email_address, password: "pw12345" }
  end

  it "貸借が一致する仕訳を作成できる" do
    expect {
      post journal_entries_path, params: {
        journal_entry: {
          date: Date.today, description: "コンビニ",
          lines: [
            { account_id: food.id, side: "debit",  amount: 50000 },
            { account_id: cash.id, side: "credit", amount: 50000 }
          ]
        }
      }
    }.to change { org_a.journal_entries.count }.by(1)

    expect(response).to have_http_status(:created)
    expect(org_a.journal_entries.last.journal_lines.count).to eq(2)
  end

  it "貸借が一致しないと422で作成されない" do
    expect {
      post journal_entries_path, params: {
        journal_entry: {
          date: Date.today, description: "壊れた仕訳",
          lines: [
            { account_id: food.id, side: "debit",  amount: 50000 },
            { account_id: cash.id, side: "credit", amount: 30000 }
          ]
        }
      }
    }.not_to change { JournalEntry.count }

    expect(response).to have_http_status(:unprocessable_content)
  end

  it "他組織の口座IDを混ぜても作成できない（認可境界）" do
    b_account = org_b.accounts.create!(name: "現金B", category: "asset")

    expect {
      post journal_entries_path, params: {
        journal_entry: {
          date: Date.today, description: "侵入",
          lines: [
            { account_id: food.id,      side: "debit",  amount: 50000 },
            { account_id: b_account.id, side: "credit", amount: 50000 }
          ]
        }
      }
    }.not_to change { JournalEntry.count }

    expect(response).to have_http_status(:unprocessable_content)
  end
end
