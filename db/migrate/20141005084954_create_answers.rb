class CreateAnswers < ActiveRecord::Migration
  def change
    create_table :answers do |t|
      t.string :message
      t.integer :gaming_session_id
      t.integer :question_id
      t.boolean :correct
      t.integer :points
      t.integer :account_id

      t.timestamps
    end
  end
end
