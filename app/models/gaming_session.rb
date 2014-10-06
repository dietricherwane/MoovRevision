class GamingSession < ActiveRecord::Base
  attr_accessible :account_id, :subscription_id, :question_type_id, :academic_level_id, :unpublished, :unpublished_at, :points, :right_answers, :wrong_answers, :expires_at, :created_at, :session_id
  
  # Scopes
  default_scope order("created_at DESC")
  
  # Relationships
  belongs_to :subscription
  belongs_to :question_type
  belongs_to :account 
  has_many :answers
end
