class CreateJournalEntries < ActiveRecord::Migration[8.1]
  def change
    create_table :journal_entries do |t|
      t.date :date
      t.string :description

      t.timestamps
    end
  end
end
