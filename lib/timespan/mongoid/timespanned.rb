module Mongoid
  module Timespanned
    extend ActiveSupport::Concern

    module ClassMethods
      def timespan_methods name
        timespan_delegates name
        timespan_setters name
      end

      # fx Account.timespan_container_delegates :period, :dates, :start, :end
      #   start_date= -> period.dates_start=
      #   end_date= -> period.dates_end=
      def timespan_container_delegates container, timespan, *names
        names = [:start, :end, :duration] if names.first == :all 
        names.flatten.each do |name|
          timespan_container_delegate container, timespan, name
        end
      end

      def timespan_container_delegate container, timespan, name      
        case name.to_sym
        when :start
          define_method "start_date=" do |date|
            send(container).send("#{timespan}_start=", date)
          end
        when :end
          define_method "end_date=" do |date|
            send(container).send("#{timespan}_end=", date)
          end
        when :duration
          define_method "duration=" do |date|
            send(container).send("#{timespan}_duration=", date)
          end
        end
      end

      def timespan_delegates name = :period
        delegate :time_left, :duration, :start_date, :end_date, to: name
      end

      def timespan_setters name = :period  
        define_method :"#{name}_start=" do |date|
          options = self.send(name) ? {end_date: self.send(name).end_date} : {}
          self.send "#{name}=", ::Timespan.new(options.merge(start_date: date))
        end

        define_method :"#{name}_end=" do |date|
          options = self.send(name) ? {start_date: self.send(name).start_date} : {}
          self.send "#{name}=", ::Timespan.new(options.merge(end_date: date))
        end

        define_method :"#{name}_duration=" do |duration|
          options = self.send(name) ? {start_date: self.send(name).start_date} : {}
          self.send "#{name}=", ::Timespan.new(options.merge(duration: duration))
        end
      end
    end
  end
end