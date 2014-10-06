class Account < ActiveRecord::Base
  attr_accessible :msisdn, :points, :right_answers, :wrong_answers, :subscription_id, :academic_level_id, :current_question, :published, :participations, :expires_at, :created_at, :daily_count
  
  # Relationships
  has_many :gaming_sessions
  has_many :answers
  belongs_to :academic_level
end
