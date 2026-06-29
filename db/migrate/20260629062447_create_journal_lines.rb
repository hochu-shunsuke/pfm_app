class CreateJournalLines < ActiveRecord::Migration[8.1]
  def change
    create_table :journal_lines do |t|
      t.references :journal_entry, null: false, foreign_key: true
      t.references :account, null: false, foreign_key: true
      t.string :side

      t.timestamps
    end
  end
end
