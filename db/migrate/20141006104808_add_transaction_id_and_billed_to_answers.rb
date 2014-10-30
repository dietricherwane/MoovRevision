class AddTransactionIdAndBilledToAnswers < ActiveRecord::Migration
  def change
    add_column :answers, :transaction_id, :string
    add_column :answers, :billed, :boolean
  end
end
