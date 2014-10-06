class CreateGamingSessions < ActiveRecord::Migration
  def change
    create_table :gaming_sessions do |t|
      t.integer :account_id
      t.integer :subscription_id
      t.integer :question_type_id
      t.integer :academic_level_id
      t.boolean :unpublished
      t.datetime :unpublished_at
      t.integer :points
      t.integer :right_answers
      t.integer :wrong_answers
      t.date :expires_at

      t.timestamps
    end
  end
end
