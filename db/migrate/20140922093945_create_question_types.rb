class CreateQuestionTypes < ActiveRecord::Migration
  def change
    create_table :question_types do |t|
      t.string :name, limit: 100
      t.boolean :published
      t.integer :ussd_id

      t.timestamps
    end
  end
end
