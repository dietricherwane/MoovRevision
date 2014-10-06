class QuestionsController < ApplicationController
  
  def index
    
  end
  
  def import
    unless params[:file].blank?
      file_name = params[:file].original_filename
      extension = File.extname(file_name) 
      full_file_name = Rails.root.join('public', 'upload', 'questions', "questions#{extension}")
      
      # Sets default sheet
      set_sheet(full_file_name, params[:file], extension)
      
      @my_sheet.last_row.times  do |n|
        n = n + 1
        # Checks if all the required rows are presents
        if valid_row(@my_sheet, n)
          @question = Question.new(wording: "#{(@my_sheet.cell(n, 1).strip rescue nil)}\na. #{(@my_sheet.cell(n, 2).strip rescue nil)}\nb. #{(@my_sheet.cell(n, 3).strip rescue nil)}\n Envoyez a ou b par SMS au #{}. Cumulez le maximum de points et gagnez de nombreux lots.", answer: (@my_sheet.cell(n, 4).strip rescue nil), points: 10, question_type_id: 2)
          @question.save
        end
      end
    end
  
    render :index
  end
  
  # initiate daily session
  def send_daily_gaming_session_question
    accounts = Account.where(published: [nil, true], daily_count: nil)
    unless accounts.blank?
      accounts.each do |account|
        @session_question_type = account.gaming_sessions.first.question_type
        @account = account
        
        set_and_send_question
      end
    end
  end
  
  # Question to send when a user registers
  def send_registration_question
    account = Account.find_by_msisdn(params[:msisdn])
    academic_level = AcademicLevel.find_by_name(params[:academic_level_id])
    
    unless academic_level
      question = QuestionType.general_knowledge_question_type.questions.where("published IS NOT FALSE AND id > #{account.current_question.to_i}").first rescue QuestionType.general_knowledge_question_type.questions.where("published IS NOT FALSE").first rescue nil
    else
      question = account.academic_level.questions.where("published IS NOT FALSE AND id > #{account.current_question.to_i}").first rescue account.academic_level.questions.where("published IS NOT FALSE").first rescue nil
    end
    
    if !question.blank?
      send_question(question.wording)
      if !@response.blank?
        account.update_attributes(current_question: question.id, daily_count: (account.daily_count + 1))
      end
    end
  end
  
  def answer
    @account = Account.find_by_msisdn(params[:msisdn])
    text = params[:text]
    if valid_gaming_session
      if (text.strip.downcase rescue nil) == "stop"
        disable_account
      else       
        if @account.daily_count < 20
          @transaction_id = DateTime.now
          # Bill the user
          billing
          if user_billed?
            # Evaluate the given answer
            question = Question.find_by_id(@account.current_question)
            correct_answer = ((text.strip.downcase rescue nil) == question.answer)
            weird_answer = ((text.strip.downcase != "a") && (text.strip.downcase != "b"))
            answer_points = (correct_answer ? question.points : 0)
            right_answer = correct_answer ? 1 : 0 
            wrong_answer = correct_answer ? 0 : 1 
            
            # Store the results
            @account.answer.create(message: text, gaming_session_id: @account.gaming_sessions.first.id, question_id: @account.current_question, correct: correct, points: answer_points, transaction_id: @transaction_id, billed: true)            
            @account.update_attributes(points: (@account.points + answer_points), right_answers: (@account.right_answers + right_answer), wrong_answers: (@account.wrong_answers + wrong_answer), participations: (@account.participations + 1))
            @valid_gaming_session.update_attributes(points: (@valid_gaming_session.points + answer_points), right_answers: (@valid_gaming_session.right_answers + right_answer), wrong_answers: (@valid_gaming_session.wrong_answers + wrong_answer))
            
            @session_question_type = @valid_gaming_session.question_type
            if weird_answer
              #send_gaming_notice
            end
            
            set_and_send_question
          else
            #could_not_be_billed
          end
        else
          # Session_over_for_today
          send_question(Error.session_over)
        end        
      end
    else
      #Create_an_account_first
    end
  end
  
  def disable_account
    if @account
      @account.update_attributes(published: false)
      @account.gaming_sessions.update_attributes(unpublished: true, unpublished_at: DateTime.now)
    end
  end
  
  def set_and_send_question
    # If we have general knowledge questions type
    if @session_question_type.academic_levels.blank?
      question = @session_question_type.questions.where("published IS NOT FALSE AND id > #{@account.current_question.to_i}").first rescue @session_question_type.questions.where("published IS NOT FALSE").first rescue nil
    else
      question = @account.academic_level.questions.where("published IS NOT FALSE AND id > #{@account.current_question.to_i}").first rescue @account.academic_level.questions.where("published IS NOT FALSE").first rescue nil
    end
    
    if !question.blank?
      send_question(question.wording)
      if !@response.blank?
        account.update_attributes(current_question: question.id, daily_count: (@account.daily_count + 1))
      end
    end
  end
  
  # Checks if the user already has a valid gaming session
  def valid_gaming_session
    @valid_gaming_session = @account.gaming_sessions.where("unpublished IS NOT FALSE AND expires_at > '#{Date.today}'").first rescue nil
    @valid_gaming_session.blank? ? false : true
  end
  
  def send_question(question)
    parameter = Parameter.first
    request = Typhoeus::Request.new(parameter.outgoing_sms_url, followlocation: true, method: :get, params: {text: URI.escape(question)})

    request.on_complete do |response|
      if response.success?
        @response = response.body
        #@response = Registration.validate_registration(@screen_id)  
      elsif response.timed_out?
        #@response = Error.timeout(@screen_id)
      elsif response.code == 0
        #@response = Error.no_http_response(@screen_id)
      else
        #@response = Error.non_successful_http_response(@screen_id)
        #@response = response.body
      end
    end

    request.run
  end
  
  # Sets default sheet
  def set_sheet(full_file_name, my_file, extension)
    File.open(full_file_name, 'wb') do |file|
      file.write(my_file.read)
    end 
          
    case extension
      when ".xls"
        @my_sheet = Roo::Excel.new(full_file_name.to_s)  
      when ".xlsx"
        @my_sheet = Roo::Excelx.new(full_file_name.to_s)
      when ".csv"
        @my_sheet = Roo::CSV.new(full_file_name.to_s)
      end
      
    @my_sheet.default_sheet = @my_sheet.sheets.first
  end
  
  # Checks if all the required rows are presents
  def valid_row(my_sheet, n)
    (!my_sheet.cell(n, 1).blank? && !my_sheet.cell(n, 2).blank? && !my_sheet.cell(n, 3).blank? && !my_sheet.cell(n, 4).blank?) ? true : false    
  end
  
  # Bill customer from moov billing platform
  def billing
    user_agent = request.env['HTTP_USER_AGENT']
    billing_request_body = Billing.request_body(@account.msisdn, @transaction_id)
    parameter = Parameter.first
    
    request = Typhoeus::Request.new(parameter.billing_url, followlocation: true, body: billing_request_body, headers: {Accept: "text/xml", :'Content-length' => billing_request_body.bytesize, Authorization: "Basic base64_encode('NGSER-MR2014:NGSER-MR2014')", :'User-Agent' => user_agent})

#=begin
    request.on_complete do |response|
      if response.success?
        result = response.body  
      elsif response.timed_out?
        result = Error.timeout(@screen_id)
      elsif response.code == 0
        result = Error.no_http_response(@screen_id)
      else
        result = Error.non_successful_http_response(@screen_id)
      end
    end

    request.run
#=end
    #response_body
    #@xml = Nokogiri.XML(Billing.response_body).xpath('//methodResponse//params//param//value//struct//member')
    @xml = Nokogiri.XML(result).xpath('//methodResponse//params//param//value//struct//member') rescue nil
    #render text: Billing.response_body.bytesize
  end
  
  # Check if the user have been billed after the return from Moov platform
  def user_billed
    if @xml.blank?
      return false
    else
      @xml.each do |result|
        if result.xpath("name").text.strip == "responseCode"
          (result.xpath("value").text.strip == "0") ? true : false
        end
      end
    end
  end
  
end
