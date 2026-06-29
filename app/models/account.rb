class Account < ApplicationRecord
    CATEGORIES = %w[asset liability equity revenue expense].freeze

    validates :name, presence: true
    validates :category, presence: true, inclusion: { in: CATEGORIES }
end
