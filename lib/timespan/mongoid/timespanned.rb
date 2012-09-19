module Mongoid
  module Timespanned
    extend ActiveSupport::Concern

    module ClassMethods
      def timespan_methods name
        timespan_delegates name
        timespan_setters name
      end

      def timespan_delegates name = :period
        delegate :time_left, :duration, :start_date, :end_date, to: name
      end

      def timespan_setters name = :period  
        define_method :"#{name}_start=" do |date|
          self.send "#{name}=", ::Timespan.new(start_date: date, end_date: self.send(name).end_date)
        end

        define_method :"#{name}_end=" do |date|
          self.send "#{name}=", ::Timespan.new(start_date: self.send(name).start_date, end_date: date)
        end

        define_method :"#{name}duration=" do |duration|
          self.send "#{name}=", ::Timespan.new(start_date: self.send(name).start_date, duration: duration)
        end
      end
    end
  end
end