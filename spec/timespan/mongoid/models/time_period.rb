class TimePeriod
  include Mongoid::Document
  include Mongoid::Timespanned

  field :dates,     :type => ::Timespan, :between => true
  field :flex,      :type => ::DurationRange

  embedded_in :account

  timespan_methods :dates

  # override defaults
  max_asap 14.days.from_now
  min_asap 2.days.ago

  asap_method :period
  duration_methods 'time_period.flex'
end