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

    def between? cfrom, cto
      case cfrom
      when Date, Time, DateTime
        unless any_kind_of?(cto, Time, Date, DateTime)
          raise ArgumentError, "Arguments must both be Date or Time, was: #{cfrom}, #{cto}"
        end
        (self.start_time.to_i >= cfrom.to_i) && (self.end_time.to_i <= cto.to_i)
      when ::Duration, String, Integer, ActiveSupport::Duration
        self >= cfrom && self <= cto
      else
        raise ArgumentError, "Not valid arguments for between comparison: #{cfrom}, #{cto}"
      end
    end

    def time_left time = nil
      time_compare = time || now
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
      when Timelord::Time
        seconds <=> time.moment
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

    protected

    def any_kind_of? obj, *types
      types.flatten.compact.any?{|type| obj.kind_of? type }
    end


    def valid_compare? time
      valid_compare_types.any? {|type| time.kind_of? type }
    end

    def valid_compare_types
      [Timespan, Time, Date, DateTime, Integer]
    end    
  end
end