class Answer < ActiveRecord::Base
  attr_accessible :message, :gaming_session_id, :question_id, :correct, :points, :account_id, :transaction_id, :billed
  
  # Relationships
  belongs_to :account
  belongs_to :question
  belongs_to :gaming_session
end
