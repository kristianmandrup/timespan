require 'timespan/mongoid/models/time_period'

class Account
  include Mongoid::Document
  include Mongoid::Timespanned

  field :name
  field :period, :type => ::Timespan, :between => true

  timespan_methods :period

  embeds_one :time_period
  
  timespan_container_delegates :time_period, :dates, :all
  timespan_container_delegates :time_period, :flex, :all

  def self.create_it! duration
    acc = self.new period: ::Timespan.new(duration: duration), time_period: ::TimePeriod.new
    acc.time_period.dates_duration = 1.day
    acc
  end

#   def to_s
#     %Q{
# name: #{name}
# }
#   end

  def self.between from, to
    Account.where(:'period.from'.gt => from.to_i, :'period.to'.lte => to.to_i)
  end
end
