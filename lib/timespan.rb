require 'duration'
require 'chronic'
require 'chronic_duration'
require 'spanner'

require 'timespan/units'
require 'timespan/compare'
require 'timespan/printer'
require 'timespan/span'

if defined?(Rails) && Rails::VERSION::STRING >= '3.1'
	require 'duration/rails/engine' 
end

class Timespan
	include Span
	include Printer
	include Compare
	include Units

	class TimeParseError < StandardError; end	

	attr_reader :start_time, :end_time

	alias_method :start_date, :start_time
	alias_method :end_date, 	:end_time

	START_KEYS 			= [:start, :from]
	END_KEYS 				= [:to, :end]
	DURATION_KEYS 	= [:duration, :lasting]

	ALL_KEYS = START_KEYS + END_KEYS + DURATION_KEYS

	def initialize options = {}
		@is_new = true

		@init_options = options
		validate! if options == {}

		case options
		when Numeric, Duration, String
			options = {:duration => options}
		end
		
		configure! options
		
		@is_new = false
	end

	def start_time= time
		@start_time = convert_to_time time		
		unless is_new?
			refresh!
			add_dirty :start
			calculate!
		end
	end
	alias_method :start_date=, :start_time=
	
	def from time
		self.start_time =	time
		self
	end

	def end_time= time
		@end_time = convert_to_time time
		unless is_new?
			add_dirty :end
			refresh!
			calculate!
		end
	end
	alias_method :end_date=, :end_time=

	def until time
		self.end_time =	time
		self
	end

	def convert_to_time time
		case time
		when String
			Chronic.parse(time)
		when Date, DateTime
			time.to_time
		when Time
			time
		else
			raise ArgumentError, "A valid time must be either a String, Date, Time or DateTime, was: #{time.inspect}"
		end
	end

	protected

	attr_reader :init_options

	def first_from keys, options = {}
		keys.select {|key| options[key] }.first
	end

	# uses init_options to configure
	def configure! options = {}
		from 	= options[first_from START_KEYS, options]
		to 		= options[first_from END_KEYS, options]
		dur 	= options[first_from DURATION_KEYS, options]

		self.duration 		= dur if dur
		self.start_time 	= from if from
		self.end_time 		= to if to

		default_from_now! unless start_time || end_time

		calculate_miss!
	rescue ArgumentError => e
		raise TimeParseError, e.message
	rescue Exception => e
		calculate_miss!
		validate!
	end		

	def default_from_now!
		self.start_time = Time.now
	end

	def validate!
		raise ArgumentError, "#{valid_requirement}, was: #{init_options.inspect} resulting in state: #{current_config}" unless valid?
	end

	def valid_requirement
		"Timespan must take 1-2 of :start_time, :end_time or :duration or simply a duration as number of seconds or a string"
	end

	def current_config
		"end time: #{end_time}, start time: #{start_time}, duration: #{duration}"
	end

	def valid?
		(end_time && start_time) || (end_time || start_time && duration)
	end

	def is_new?
		@is_new
	end

	def dirty
		@dirty ||= []
	end

	def add_dirty type
		reset_dirty if dirty.size > 2
		dirty << type
	end

	def reset_dirty
		@dirty = []
	end

	def dirty? type
		dirty.include? type
	end

	def calculate!
		set_duration unless dirty? :duration
		set_start_time unless dirty? :start
		set_end_time unless dirty? :end		
	end

	def calculate_miss!
		set_end_time_miss
		set_start_time_miss	
		set_duration_miss
		set_end_time_miss	
		set_start_time_miss
	end

	def set_end_time_miss		
		set_end_time if missing_end_time?
	end

	def set_end_time
		self.end_time = start_time - duration.total
	end

	def set_start_time_miss
		 set_start_time if missing_start_time?
	end

	def set_start_time
		self.start_time = end_time - duration.total
	end

	def set_duration_miss
		set_duration if missing_duration?
	end

	def set_duration
		self.duration = end_time - start_time
	end

	def missing_end_time?
		start_time && duration && !end_time
	end

	def missing_start_time?
		end_time && duration && !start_time
	end

	def missing_duration?
		start_time && end_time && !duration
	end

	# reset all stored instance vars for units
	def refresh!
		units.each do |unit| 
			var_name = :"@#{unit}"
			instance_variable_set var_name, nil
		end
	end
end