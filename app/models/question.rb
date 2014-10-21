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
  
  # unpublish expired accounts
  def self.unpublish_expired_accounts
    accounts = Account.where("expires_at < '#{Date.today}'")
    unless accounts.blank?
      accounts.each do |account|
        account.update_attributes(published: false)
        account.gaming_sessions.first.update_attributes(unpublished: false, unpublished_at: DateTime.now)
      end
    end
  end
  
  # reset daily session
  def self.reset_daily_gaming_session_question
    accounts = Account.where(published: [nil, true])
    unless accounts.blank?
      accounts.each do |account|
        account.update_attributes(daily_count: 0)
      end
    end
  end
  
  # initiate daily session
  def self.send_daily_gaming_session_question
    accounts = Account.where(published: [nil, true], daily_count: [nil, 0])
    unless accounts.blank?
      accounts.each do |account|
        @session_question_type = account.gaming_sessions.first.question_type
        
        # If we have general knowledge questions type
        if @session_question_type.academic_levels.blank?
          question = @session_question_type.questions.where("published IS NOT FALSE AND id > #{account.current_question.to_i}").first rescue nil
          question = @session_question_type.questions.where("published IS NOT FALSE").first rescue nil
        else
          question = account.academic_level.questions.where("published IS NOT FALSE AND id > #{account.current_question.to_i}").first rescue nil
          question = account.academic_level.questions.where("published IS NOT FALSE AND id > 0").first rescue nil
        end
        
        if !question.blank?
          #send_question(question.wording)
          parameter = Parameter.first
          #request = Typhoeus::Request.new("#{parameter.outgoing_sms_url}to=#{account.msisdn}&text=#{URI.escape(question.wording)}", followlocation: true, method: :get)
          request = Typhoeus::Request.new("#{parameter.outgoing_sms_url}to=#{@account.msisdn}&text='#{question.force_encoding("utf-8")}'", followlocation: true, method: :get)
          request.on_complete do |response|
            if response.success?
              @response = (response.body.to_s.strip == "0: Accepted for delivery" || response.body.to_s.strip == "3: Queued for later delivery")
            elsif response.timed_out?
              @response = false
            elsif response.code == 0
              @response = false
            else
              @response = false
            end
          end

          request.run
          if @response == true
            account.update_attributes(current_question: question.id, daily_count: (account.daily_count.to_i + 1))
          end
        end
      end
    end
  end

end
