class Account
  include Mongoid::Document
    
  field :period, :type => TimeSpan, :between => true

  def self.create_it! duration
    s = self.new
    s.period = {duration: duration}
    s
  end

  def self.between from, to
    Account.where(:'period.from'.gt => from.to_i, :'period.to'.lte => to.to_i)
  end
end
