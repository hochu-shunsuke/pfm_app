class AddOrganizationToJournalEntries < ActiveRecord::Migration[8.1]
  def change
    add_reference :journal_entries, :organization, null: false, foreign_key: true
  end
end
