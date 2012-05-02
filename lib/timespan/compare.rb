class Timespan
  module Compare

  	include Comparable

    def time_left time = nil
      time_compare = time || Time.now
      Duration.new(end_time - time_compare)
    end

    def expired?
      time_left <= 0
    end

    def <=> time
    	raise ArgumentError, "Not a valid argument for Timespan comparison, was #{time}" unless valid_compare?(time)
    	case time
    	when Timespan
    		millis <=> time.seconds
    	when Time  		
      	millis <=> time.to_i
      when Date, DateTime
      	time.to_time.to_i
      when Integer
      	millis <=> time
      end
    end

    def valid_compare? time
      valid_compare_types.any? {|type| time.kind_of? type }
    end

    def valid_compare_types
      [Timespan, Time, Date, DateTime, Integer]
    end    
  end
end