class TimePeriod
  include Mongoid::Document
  include Mongoid::Timespanned

  field :dates,     :type => ::Timespan, :between => true
  field :flex,      :type => ::DurationRange

  embedded_in :account

  timespan_methods :dates
end