class CreateQuestions < ActiveRecord::Migration
  def change
    create_table :questions do |t|
      t.text :wording
      t.text :answer, limit: 5
      t.integer :points
      t.integer :academic_level_id
      t.integer :question_type_id
      t.boolean :published

      t.timestamps
    end
  end
end
