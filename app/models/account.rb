class Account < ApplicationRecord
    belongs_to :organization
    
    CATEGORIES = %w[asset liability equity revenue expense].freeze
    
    has_many :journal_lines

    validates :name, presence: true
    validates :category, presence: true, inclusion: { in: CATEGORIES }

    def balance
        debit = journal_lines.where(side: "debit").sum(:amount)
        credit = journal_lines.where(side: "credit").sum(:amount)
        debit - credit
    end
end
