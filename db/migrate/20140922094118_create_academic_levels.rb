class CreateAcademicLevels < ActiveRecord::Migration
  def change
    create_table :academic_levels do |t|
      t.string :name, limit: 100
      t.integer :question_type_id
      t.boolean :published
      t.integer :ussd_id

      t.timestamps
    end
  end
end
