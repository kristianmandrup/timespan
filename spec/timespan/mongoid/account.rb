class Account
	include Mongoid::Document
	field :period, :type => TimeSpan

  def self.create_it! duration
    s = self.new
    s.period = {duration: duration}
    s
  end
end
