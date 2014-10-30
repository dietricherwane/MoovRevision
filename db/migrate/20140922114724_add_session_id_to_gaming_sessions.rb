class AddSessionIdToGamingSessions < ActiveRecord::Migration
  def change
    add_column :gaming_sessions, :session_id, :string
  end
end
