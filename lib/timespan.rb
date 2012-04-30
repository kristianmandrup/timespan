require 'duration'
require 'spanner'

class TimeSpan
	class ParseError < StandardError; end

	attr_reader :start_time, :end_time, :seconds

	alias_method :start_date, :start_time
	alias_method :end_date, 	:end_time

	def initialize options = {}
		@is_new = true

		set_with_options options		
		
		@is_new = false
	end

	def start_time= start_time
		@start_time = start_time
		refresh!
	end
	alias_method :start_date=, :start_time=

	def end_time= start_time
		@start_time = start_time
		refresh!
	end
	alias_method :end_date=, :end_time=

	def seconds= seconds 
		@seconds = seconds
		refresh!	
	end

	def duration
		@duration ||= Duration.new(seconds)
	end

	def duration= duration
		@duration = case duration
		when Duration
			duration
		when Integer, Hash
			Duration.new duration
		when String
			begin				
				Duration.new Spanner.parse(duration.gsub /and/, '')
			rescue Exception => e
				raise ParseError, "Internal error: Spanner couldn't parse String '#{duration}'"
			end
		else
			raise ArgumentError, "the duration option must be set to any of: #{valid_duration_types}"
		end		 
		refresh! unless is_new?
	end
		
	def to_s
		if duration
			"TimeSpan: from #{start_time} lasting #{duration} = #{seconds} secs" if start_time
			"TimeSpan: from #{end_time} to #{duration} before = #{seconds} secs" if end_time
			return
		end

		if start_time && end_time
			"TimeSpan: #{start_time} to #{end_time} = #{seconds} secs"			
			return
		end

		if seconds
			"TimeSpan: #{seconds} seconds"
		end
	end

	include Comparable

  def <=> time
  	raise ArgumentError, "Not a valid argument for timespan comparison, was #{time}" unless valid_compare?(time)
  	case time
  	when TimeSpan
  		millis <=> time.seconds
  	when Time  		
    	millis <=> time.to_i
    when Date, DateTime
    	time.to_time.to_i
    when Integer
    	millis <=> time
    end
  end

	alias_method :to_secs, 		:seconds
	alias_method :to_seconds, :seconds

	def to_milliseconds
		@to_seconds ||= (seconds * 1000.0).round
	end
	alias_method :to_mils, 	 			:to_milliseconds
	alias_method :millis, 	 			:to_mils
	alias_method :milliseconds, 	:to_mils

	def to_minutes
		@to_minutes ||= (to_seconds / 60.0).round
	end
	alias_method :to_m, 		:to_minutes
	alias_method :to_mins, 	:to_minutes
	alias_method :minutes, 	:to_minutes

	def to_hours
		@to_hours ||= (to_minutes / 60.0).round
	end
	alias_method :to_h, 	:to_hours
	alias_method :hrs, 		:to_hours
	alias_method :hours, 	:to_hours

	def to_days
		@to_days ||= (to_hours / 24.0).round
	end	
	alias_method :to_d, :to_days
	alias_method :days, :to_days

	def to_weeks
		@to_weeks ||= (to_days / 7.0).round
	end	
	alias_method :to_w, 	:to_weeks
	alias_method :weeks, 	:to_days

	def to_months
		@to_months ||= (to_days / 30.0).round
	end	
	alias_method :to_mon, :to_months
	alias_method :months, :to_months

	def to_years
		@to_years ||= (to_days.to_f / 365.25).round
	end	
	alias_method :to_y, 	:to_years
	alias_method :years, 	:to_years

	def to_decades
		@to_decades ||= (to_years / 10.0).round
	end	
	alias_method :decades, 	:to_decades

	def to_centuries
		@to_centuries ||= (to_decades / 10.0).round
	end	
	alias_method :centuries, 	:to_centuries

	def units
		%w{seconds minutes hours days weeks months years}
	end

	protected

	def set_with_options options = {}		
		case options
		when Hash
			duration 		= options[:duration]
			@start_time = options[:from] || options[:start]
			@end_time 	= options[:to] || options[:end]
		when Integer, String
			duration   = options
		else
			raise ArgumentError, "Timespan must take Hash or Integer, was: #{options}"
		end

		set_seconds options
	end		

	def set_seconds options = nil
		set_seconds_opts(options)

		unless @duration
			if @end_time && @start_time
				@seconds 	||= (@end_time - @start_time).to_i
			end
		else
			@seconds 	||= @duration.total
		end
	end

	def set_seconds_opts options = {}
		case options
		when Integer
			@seconds = options
		when Hash
			@seconds = options[:seconds] if options[:seconds]
			self.duration = options[:duration] if options[:duration]
		end
	end

	def is_new?
		@is_new
	end

	# reset all stored instance vars for units
	def refresh!
		units.each do |unit| 
			var_name = :"@#{unit}"
			instance_variable_set var_name, nil
		end
		set_seconds
	end

	def valid_duration_types
		[Duration, String, Integer, Hash]
	end

	def valid_compare? time
		valid_compare_types.any? {|type| time.kind_of? type }
	end

	def valid_compare_types
		[TimeSpan, Time, Date, DateTime, Integer]
	end
end