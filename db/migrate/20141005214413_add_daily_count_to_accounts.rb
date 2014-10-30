class AddDailyCountToAccounts < ActiveRecord::Migration
  def change
    add_column :accounts, :daily_count, :integer
  end
end
