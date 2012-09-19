module Mongoid
  module Timespanned
    extend ActiveSupport::Concern

    module ClassMethods
      # fx Account.timespan_container_delegates :period, :dates, :start, :end
      #   start_date= -> period.dates_start=
      #   end_date= -> period.dates_end=
      def timespan_container_delegates container, timespan, *names
        options = names.extract_options!
        names = [:start, :end, :duration] if names.first == :all || names.empty?
        names.flatten.each do |name|
          timespan_container_delegate container, timespan, name, options = {}
        end
      end

      def timespan_container_delegate container, timespan, name, options = {}
        override = options[:override]
        case name.to_sym
        when :start
          meth = "start_date="
          raise ArgumentError, "method #{meth} already defined on #{self}" if self.respond_to?(meth) && ! override
          define_method meth do |date|            
            self.send(container).send("#{timespan}_start=", date)
          end
        when :end
          meth = "end_date="
          raise ArgumentError, "method #{meth} already defined on #{self}" if self.respond_to?(meth) && !override
          define_method meth do |date|
            self.send(container).send("#{timespan}_end=", date)
          end
        when :duration
          meth = "duration="
          raise ArgumentError, "method duration= already defined on #{self}" if self.respond_to?(meth) && !override
          define_method meth do |date|
            self.send(container).send("#{timespan}_duration=", date)
          end
        end
      end

      def timespan_methods target = :period, *names
        options = names.extract_options!        
        names = [:start, :end, :duration] if names.first == :all || names.empty?
        timespan_delegates target, names, options
        timespan_setters target, names, options
      end      

      def timespan_delegates target = :period, *names
        options = names.extract_options!
        names = names.flatten
        names = [:start_date, :end_date, :duration] if names.first == :all || names.empty?
        names.map! do |name|
          case name.to_sym
          when :start then :start_date
          when :end then :end_date
          else
            name.to_sym
          end
        end
        names.flatten.each do |name|
          timespan_delegate name, target, options
        end
      end

      def timespan_delegate meth, target = :period, options = {}
        override = options[:override]
        raise ArgumentError, "method #{meth} already defined on #{self}" if self.respond_to?(meth) && !override
        delegate meth, to: target
      end

      def timespan_setters target = :period, *names
        options = names.extract_options!
        names = [:start, :end, :duration] if names.first == :all || names.empty?

        names.flatten.each do |name|
          timespan_setter target, name, options
        end
      end

      def timespan_setter name, meth_name, options = {}
        override = options[:override]
        case meth_name.to_sym
        when :start
          meth = "#{name}_start="
          raise ArgumentError, "method #{meth} already defined on #{self}" if self.respond_to?(meth) && !override

          define_method :"#{name}_start=" do |date|
            options = self.send(name) ? {end_date: self.send(name).end_date} : {}
            timespan = ::Timespan.new(options.merge(start_date: date))
            self.send "#{name}=", timespan
          end
        when :end
          meth = "#{name}_end="
          raise ArgumentError, "method #{meth} already defined on #{self}" if self.respond_to?(meth) && !override

          define_method :"#{name}_end=" do |date|
            options = self.send(name) ? {start_date: self.send(name).start_date} : {}
            timespan = ::Timespan.new(options.merge(end_date: date))
            self.send "#{name}=", timespan
          end
        when :duration
          meth = "#{name}_duration="
          raise ArgumentError, "method #{meth} already defined on #{self}" if self.respond_to?(meth) && !override

          define_method :"#{name}_duration=" do |duration|
            options = self.send(name) ? {start_date: self.send(name).start_date} : {}
            timespan = ::Timespan.new(options.merge(duration: duration))
            self.send "#{name}=", timespan
          end
        end
      end
    end
  end
end