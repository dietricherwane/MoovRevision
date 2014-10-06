class Question < ActiveRecord::Base
  attr_accessible :wording, :answer, :points, :academic_level_id, :question_type_id, :published, :id
  
  # Relationships
  belongs_to :question_type
  belongs_to :academic_level
  has_many :answers
  
  # Scopes
  default_scope order("id ASC")
  
  # Validations
  validates :wording, :answer, :points, :question_type_id, presence: true
  validates :academic_level_id, presence: true, if: :scholar_questions_type
  
  # Custom functions
  def scholar_questions_type
    question_type.scholar_question_type
  end

end
