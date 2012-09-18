class Account
  include Mongoid::Document

  field :period, :type => ::Timespan, :between => true

  delegate :start_date, to: :period

  def start_date= date
    self.period = ::Timespan.new(start_date: date, end_date: self.period.end_date)
  end

  def self.create_it! duration
    t = ::Timespan.new(duration: duration)
    self.new period: t
  end

  def self.between from, to
    Account.where(:'period.from'.gt => from.to_i, :'period.to'.lte => to.to_i)
  end
end
