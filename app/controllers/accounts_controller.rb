class AccountsController < ApplicationController

  def create
    @subscription_id = params[:subscription_id]
    @question_type_id = params[:question_type_id]
    @academic_level_id = params[:academic_level_id]
    @session_id = params[:session_id] 
    @msisdn = params[:msisdn]   
    @screen_id = params[:screen_id]
    
    create_account
    
    render text: @response
  end
  
  def create_account
    subscription = Subscription.find_by_id(@subscription_id)
    
    set_account(subscription)
    
    if @account
      if @new_account
        create_gaming_session  
      else
        # If the user already has a valid gaming session
        if valid_gaming_session
          @response = Error.valid_gaming_session(@valid_gaming_session, @screen_id)
        else
          create_gaming_session
        end
      end
    else
      @response = Error.create_account(@screen_id)   
    end
  end
  
  # Checks if the user already has a valid gaming session
  def valid_gaming_session
    @valid_gaming_session = @account.gaming_sessions.where("unpublished IS NOT FALSE AND expires_at > '#{Date.today}'").first rescue nil
    @valid_gaming_session.blank? ? false : true
  end
  
  # Sets account variable with an existing account or by creating a new one
  def set_account(subscription)
    @account = Account.find_by_msisdn(@msisdn)
    if @account.blank?
      @account = Account.create(msisdn: @msisdn, subscription_id: @subscription_id, academic_level_id: @academic_level_id, expires_at: Date.today + subscription.duration) rescue nil
      @new_account = true
    end
  end
  
  # Create gaming session and sets the correct response
  def create_gaming_session
    @gaming_session = @account.gaming_sessions.create(subscription_id: @subscription_id, question_type_id: @question_type_id, academic_level_id: @academic_level_id, session_id: @session_id, expires_at: @account.expires_at) rescue nil
    if @gaming_session
      @account.update_attributes(published: true)
      @response = Registration.validate_registration(@screen_id)
    else
      @response = Error.create_gaming_session(@screen_id)
    end
  end
  
end
