class Organization < ApplicationRecord
    has_many :users, dependent: :destroy
    has_many :accounts, dependent: :destroy
    has_many :journal_entries, dependent: :destroy
end
