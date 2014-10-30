class CreateAccounts < ActiveRecord::Migration
  def change
    create_table :accounts do |t|
      t.string :msisdn, limit: 16
      t.integer :subscription_id
      t.integer :academic_level_id
      t.integer :points
      t.integer :right_answers
      t.integer :wrong_answers
      t.integer :current_question
      t.integer :participations
      t.boolean :published
      t.date :expires_at

      t.timestamps
    end
  end
end
