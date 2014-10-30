namespace :account do
  desc "Unpublish expired_accounts at 00:01 AM"
	task :unpublish_expired_accounts => :environment do
	  Question.unpublish_expired_accounts
	end
end
