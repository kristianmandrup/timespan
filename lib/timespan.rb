class TimeSpan
	attr_reader :start_time, :end_time, :seconds

	def initialize options = {}
		@start_time = options[:from]
		@end_time 	= options[:to]
		@reverse 		= options[:reverse]
		@seconds 		= (end_time - start_time).to_i
	end

	def to_s
		"TimeSpan: #{start_time} to #{end_time} = #{seconds} secs"
	end

	include Comparable

  def <=> time
  	raise ArgumentError, "Not a valid argument for timespan comparison, was #{time}" unless valid_compare?(time)
  	case time
  	when TimeSpan
  		millis <=> time.millis 
  	when Time  		
    	millis <=> (time.usec * 1000)
    when Date, DateTime
    	(time.to_time.usec * 1000)
    when Integer
    	millis <=> time
    end
  end

	alias_method :to_secs, 		:seconds
	alias_method :to_seconds, :seconds

	def to_milliseconds
		@to_seconds ||= (seconds * 1000.0).round
	end
	alias_method :to_mils, 	 :to_milliseconds
	alias_method :millis, 	 :to_mils

	def to_minutes
		@to_minutes ||= (to_seconds / 60.0).round
	end
	alias_method :to_m, 		:to_minutes
	alias_method :to_mins, 	:to_minutes

	def to_hours
		@to_hours ||= (to_minutes / 60.0).round
	end
	alias_method :to_h, :to_hours

	def to_days
		@to_days ||= (to_hours / 24).round
	end	
	alias_method :to_d, :to_days

	def to_weeks
		@to_weeks ||= (to_days / 7).round
	end	
	alias_method :to_w, :to_weeks

	def to_months
		@to_months ||= (to_days / 30).round
	end	
	alias_method :to_mon, :to_months

	def to_years
		@to_years ||= (to_days.to_f / 365.25).round
	end	
	alias_method :to_y, :to_years

	protected

	def valid_compare? time
		valid_compare_types.any? {|type| time.kind_of? type }
	end

	def valid_compare_types
		[TimeSpan, Time, Date, DateTime, Integer]
	end
end