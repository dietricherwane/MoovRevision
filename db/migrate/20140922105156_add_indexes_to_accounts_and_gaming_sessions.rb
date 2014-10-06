class AddIndexesToAccountsAndGamingSessions < ActiveRecord::Migration
  def change
    add_index :accounts, :msisdn
    add_index :accounts, :subscription_id
    add_index :accounts, :academic_level_id
    add_index :gaming_sessions, :account_id
    add_index :gaming_sessions, :subscription_id
    add_index :gaming_sessions, :question_type_id
    add_index :gaming_sessions, :academic_level_id
  end
end
