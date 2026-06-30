class Account < ApplicationRecord
  belongs_to :organization

  CATEGORIES = %w[asset liability equity revenue expense].freeze
  # 借方が増える勘定(資産・費用)。残高 = 借方 - 貸方。
  # それ以外(負債・純資産・収益)は貸方が増えるので符号を反転する。
  DEBIT_NORMAL_CATEGORIES = %w[asset expense].freeze

  has_many :journal_lines

  validates :name, presence: true
  validates :category, presence: true, inclusion: { in: CATEGORIES }

  def debit_normal?
    DEBIT_NORMAL_CATEGORIES.include?(category)
  end

  # 単体の残高(1/100円単位)。勘定種類に応じた符号で返す。
  def balance
    debit  = journal_lines.where(side: "debit").sum(:amount)
    credit = journal_lines.where(side: "credit").sum(:amount)
    raw = debit - credit
    debit_normal? ? raw : -raw
  end

  # 複数口座の残高を「1クエリ」でまとめて算出する(N+1回避)。
  # 戻り値: { account_id => 残高(符号補正済み) }
  def self.balances_for(accounts)
    accounts = accounts.to_a
    # group(:account_id, :side).sum(:amount) で全口座の借方/貸方合計を1回のSQLで取得
    sums = JournalLine.where(account_id: accounts.map(&:id))
                      .group(:account_id, :side)
                      .sum(:amount)
    accounts.each_with_object({}) do |account, result|
      debit  = sums[[account.id, "debit"]]  || 0
      credit = sums[[account.id, "credit"]] || 0
      raw = debit - credit
      result[account.id] = account.debit_normal? ? raw : -raw
    end
  end
end
