class AddAmountToJournalLines < ActiveRecord::Migration[8.1]
  def change
    add_column :journal_lines, :amount, :integer, null:false
    change_column_null :journal_lines, :side, false
  end
end
