class Account
  include Mongoid::Document
  include Mongoid::Timespanned

  field :period, :type => ::Timespan, :between => true

  timespan_methods :period

  def self.create_it! duration
    self.new period: ::Timespan.new(duration: duration)
  end

  def self.between from, to
    Account.where(:'period.from'.gt => from.to_i, :'period.to'.lte => to.to_i)
  end
end
