class JournalLine < ApplicationRecord
  belongs_to :journal_entry
  belongs_to :account
  
  validates :side, inclusion: { in: %w[debit credit] }
  validates :amount, numericality: { greater_than: 0 }
end
