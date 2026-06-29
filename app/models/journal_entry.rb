class JournalEntry < ApplicationRecord
    has_many :journal_lines, dependent: :destroy
end
