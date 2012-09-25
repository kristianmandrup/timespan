class TimePeriod
  include Mongoid::Document
  include Mongoid::Timespanned

  field :dates,     :type => ::Timespan, :between => true
  field :flex,      :type => ::DurationRange

  embedded_in :account

  timespan_methods :dates

  def max_asap
    10.days.from_now.to_i
  end

  def min_asap
    1.day.ago.to_i
  end

  asap_method :period
  duration_methods 'time_period.flex'
end