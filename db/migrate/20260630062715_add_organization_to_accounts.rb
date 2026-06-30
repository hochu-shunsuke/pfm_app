class AddOrganizationToAccounts < ActiveRecord::Migration[8.1]
  def change
    add_reference :accounts, :organization, null: false, foreign_key: true
  end
end
