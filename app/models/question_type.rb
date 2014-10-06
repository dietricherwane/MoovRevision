class QuestionType < ActiveRecord::Base
  attr_accessible :name, :published, :ussd_id
  
  # Relationships
  has_many :gaming_sessions
  has_many :academic_levels
  has_many :questions
  
  # Custom functions
  def self.scholar_question_type
    URI.escape(name) == URI.escape("Révision scolaire") ? true : false
  end
  
  def self.general_knowledge_question_type
    return QuestionType.find_by_name("Culture générale")
  end
end
