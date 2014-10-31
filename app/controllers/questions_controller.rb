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
          @question = Question.new(wording: "#{@my_sheet.cell(n, 1).strip}\na. #{@my_sheet.cell(n, 2).strip}\nb. #{@my_sheet.cell(n, 3).strip}\n Envoyez a ou b par SMS au #{}.", answer: @my_sheet.cell(n, 4).strip, points: 10, question_type_id: 2)
          @question.save
        end
      end
    end

    render :index
  end

  # initiate daily session
  def send_daily_gaming_session_question
    accounts = Account.where(published: [nil, true], daily_count: [nil, 0])
    unless accounts.blank?
      accounts.each do |account|
        @session_question_type = account.gaming_sessions.first.question_type
        @account = account

        set_and_send_question
      end
    end

    render text: "0"
  end

  # Question to send when a user registers
  def send_registration_question
    @account = Account.find_by_msisdn(params[:msisdn])
    academic_level = AcademicLevel.find_by_id(params[:academic_level_id])

    unless academic_level
      question = QuestionType.general_knowledge_question_type.questions.where("published IS NOT FALSE AND id > #{@account.current_question.to_i}").first rescue QuestionType.general_knowledge_question_type.questions.where("published IS NOT FALSE").first rescue nil
    else
      question = @account.academic_level.questions.where("published IS NOT FALSE AND id > #{@account.current_question.to_i}").first rescue @account.academic_level.questions.where("published IS NOT FALSE").first rescue nil
    end

    if !question.blank?
      send_question(question.wording)
      if @response
        @account.update_attributes(current_question: question.id, daily_count: (@account.daily_count.to_i + 1))
      end
    end

    render text: @response
  end

  def answer
    @account = Account.find_by_msisdn(params[:SOA])
    text = params[:Content]
    if valid_gaming_session
      if (text.strip.downcase rescue nil) == "stop"
        disable_account
      else
        if @account.daily_count.to_i < 20
          @transaction_id = DateTime.now
          # Bill the user
          #billing
          if billing
            # Evaluate the given answer
            question = Question.find_by_id(@account.current_question)
            correct_answer = ((text.strip.downcase rescue nil) == question.answer)
            weird_answer = ((text.strip.downcase != "a") && (text.strip.downcase != "b"))
            answer_points = (correct_answer ? question.points : 0)
            right_answer = correct_answer ? 1 : 0
            wrong_answer = correct_answer ? 0 : 1

            # Store the results
            @account.answers.create(message: text, gaming_session_id: @account.gaming_sessions.first.id, question_id: @account.current_question, correct: correct_answer, points: answer_points, transaction_id: @transaction_id, billed: true)
            @account.update_attributes(points: (@account.points.to_i + answer_points), right_answers: (@account.right_answers.to_i + right_answer), wrong_answers: (@account.wrong_answers.to_i + wrong_answer), participations: (@account.participations.to_i + 1))
            @valid_gaming_session.update_attributes(points: (@valid_gaming_session.points.to_i + answer_points), right_answers: (@valid_gaming_session.right_answers.to_i + right_answer), wrong_answers: (@valid_gaming_session.wrong_answers.to_i + wrong_answer))

            @session_question_type = @valid_gaming_session.question_type
            if weird_answer
              #send_gaming_notice
              send_question(Error.gaming_notice)
            end

            # send_gaming_report
            send_question("Vous avez #{correct_answer ? 'donné la bonne réponse. Félicitations!' : 'donné la mauvaise réponse.'} Vous cumulez: #{@account.points} points. Continuez de jouer pour gagner de nombreux lots.")

            set_and_send_question
          else
            #could_not_be_billed
            send_question(Error.could_not_be_billed)
          end
        else
          # Session_over_for_today
          send_question(Error.session_over)
        end
      end
    else
      #Create_an_account_first
      send_question(Error.create_an_account_first)
    end

    render text: "0"
  end

  def disable_account
    if @account
      @account.update_attributes(published: false)
      @account.gaming_sessions.first.update_attributes(unpublished: true, unpublished_at: DateTime.now)
      send_question(Error.disable_account)
    end
  end

  def set_and_send_question
    # If we have general knowledge questions type
    if @session_question_type.academic_levels.blank?
      question = @session_question_type.questions.where("published IS NOT FALSE AND id > #{@account.current_question.to_i}").first rescue nil
      if question.blank?
        question = @session_question_type.questions.where("published IS NOT FALSE").first rescue nil
      end
    else
      question = @account.academic_level.questions.where("published IS NOT FALSE AND id > #{@account.current_question.to_i}").first rescue nil
      if question.blank?
        question = @account.academic_level.questions.where("published IS NOT FALSE AND id > 0").first rescue nil
      end
    end

    if question != blank?
      send_question(question.wording)
      if @response == true
        @account.update_attributes(current_question: question.id, daily_count: (@account.daily_count.to_i + 1))
      end
    end
  end

  # Checks if the user already has a valid gaming session
  def valid_gaming_session
    @valid_gaming_session = @account.gaming_sessions.where("unpublished IS NOT TRUE AND expires_at > '#{Date.today}'").first rescue nil
    @valid_gaming_session.blank? ? false : true
  end

  def send_question(question)
    parameter = Parameter.first
    #request = Typhoeus::Request.new("#{parameter.outgoing_sms_url}to=#{@account.msisdn}&text=#{URI.escape(question)}", followlocation: true, method: :get)
    request = Typhoeus::Request.new("#{parameter.outgoing_sms_url}to=#{@account.msisdn}&text=#{URI.escape(question.wording)}", followlocation: true, method: :get)
    #request = Typhoeus::Request.new("#{parameter.outgoing_sms_url}to=#{@account.msisdn}&text=#{URI.escape(question)}", followlocation: true, method: :get)

    request.on_complete do |response|
      if response.success?
        @response = ((response.body.strip rescue nil) == "0: Accepted for delivery")
      elsif response.timed_out?
        @response = false
      elsif response.code == 0
        @response = false
      else
        @response = false
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
    (!(my_sheet.cell(n, 1).strip rescue nil).blank? && !(my_sheet.cell(n, 2).strip rescue nil).blank? && !(my_sheet.cell(n, 3).strip rescue nil).blank? && !(my_sheet.cell(n, 4).strip rescue nil).blank?) ? true : false
  end

  # Bill customer from moov billing platform
  def billing
    user_agent = request.env['HTTP_USER_AGENT']
    #parameter = Parameter.first
    transaction_id = DateTime.now.to_i

    request = Typhoeus::Request.new("http://37.0.73.3:3778", followlocation: true, params: {transaction_id: transaction_id, msisdn: @account.msisdn, price: "50"})

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
    return ((result.strip rescue nil) == "1" ? true : false)
  end

end
