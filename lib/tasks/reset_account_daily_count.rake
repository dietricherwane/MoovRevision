namespace :account do
  desc "Reset Account daily count to 0 at 00:01 AM"
	task :reset_daily_count => :environment do
	  Question.reset_daily_gaming_session_question
	end
end
