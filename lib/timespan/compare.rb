class Timespan
  class TimeDuration
    include Timespan::Units

    attr_reader :duration, :reverse

    def initialize duration, options = {}
      @duration = ::Duration.new(duration)
      @reverse = options[:reverse] || (@duration.total < 0)
    end

    def total
      reverse ? -(duration.total.abs) : duration.total
    end

    def self.create_reverse duration
      self.new duration, :reverse => true
    end
  end

  module Compare
  	include Comparable

    def time_left time = nil
      time_compare = time || Time.now
      diff = end_time - time_compare
      Timespan::TimeDuration.new(diff)
    end

    def expired?
      time_left.total <= 0
    end

    def <=> time
    	raise ArgumentError, "Not a valid argument for Timespan comparison, was #{time}" unless valid_compare?(time)
    	case time
    	when Timespan
    		seconds <=> time.seconds
    	when Time  		
      	seconds <=> time.to_i
      when Date, DateTime
      	time.to_time.to_i
      when Integer
      	seconds <=> time
      when ActiveSupport::Duration
        seconds <=> time.to_i
      end
    end

    def +(other)
      self.duration += Duration.new(other)
      self
    end

    def -(other)
      self.duration -= Duration.new(other)
      self
    end


    def valid_compare? time
      valid_compare_types.any? {|type| time.kind_of? type }
    end

    def valid_compare_types
      [Timespan, Time, Date, DateTime, Integer]
    end    
  end
end