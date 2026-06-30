class JournalEntry < ApplicationRecord
    belongs_to :organization
    
    has_many :journal_lines, dependent: :destroy

    validate :debit_credit_must_balance

    private

    def debit_credit_must_balance
        debit  = journal_lines.select { |l| l.side == "debit"  }.sum { |l| l.amount }
        credit = journal_lines.select { |l| l.side == "credit" }.sum { |l| l.amount }

        if debit != credit
            errors.add(:base, "貸借が一致しません（借方#{debit} / 貸方#{credit}）")
        end
    end
end