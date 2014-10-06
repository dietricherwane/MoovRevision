class CreateSubscriptions < ActiveRecord::Migration
  def change
    create_table :subscriptions do |t|
      t.string :name, limit: 100
      t.integer :duration
      t.integer :price
      t.integer :ussd_id

      t.timestamps
    end
  end
end
