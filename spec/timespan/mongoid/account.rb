puts "Account"

class Account
	include Mongoid::Document
	field :period, :type => ::TimeSpan
end
