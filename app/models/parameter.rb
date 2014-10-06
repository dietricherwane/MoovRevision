class Parameter < ActiveRecord::Base
  attr_accessible :outgoing_sms_url, :billing_url
end
