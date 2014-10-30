namespace :question do
  desc "Sends questions every day at 8 AM"
	task :send_daily_question => :environment do  
	  Question.send_daily_gaming_session_question
	end
end
