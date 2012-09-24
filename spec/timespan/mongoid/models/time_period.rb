class TimePeriod
  include Mongoid::Document
  include Mongoid::Timespanned

  field :dates, :type => ::Timespan, :between => true
  field :duration, :type => ::Timespan, :between => true

  embedded_in :account

  timespan_methods :dates
end