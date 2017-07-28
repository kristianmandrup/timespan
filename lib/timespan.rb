require 'active_support/dependencies/autoload'
require 'duration'
require 'chronic'
require 'chronic_duration'
require 'spanner'

# Range intersection that works with dates!
require 'sugar-high/range'
require 'sugar-high/delegate'
require 'sugar-high/kind_of'

require 'timespan/core_ext'

require 'timespan/units'
require 'timespan/compare'
require 'timespan/printer'
require 'timespan/span'
require 'active_support/core_ext/date/calculations.rb'

if defined?(Mongoid)
	require 'timespan/mongoid'
end

if defined?(Rails) && Rails::VERSION::STRING >= '3.1'
	require 'duration/rails/engine' 
end

class Date
	def self.next_week
		Date.today.next_week
	end
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

	START_KEYS 			= [:start, :from, :start_date, :start_time, :start_from, :starting]
	END_KEYS 				= [:to, :end, :end_date, :end_at, :ending]
	DURATION_KEYS 	= [:duration, :lasting, :"for"]

	ALL_KEYS = START_KEYS + END_KEYS + DURATION_KEYS

	def initialize options = {}
		@is_new = true
		@init_options = options
		validate! if options == {}

		options = {:duration => options} if options.kind_of? Numeric
		
		if duration_classes.any?{|clazz| options.kind_of? clazz }
			options = {:duration => options}
		end
		
		configure! options
		
		@is_new = false
	end

	def duration_classes
		[::Duration, ::String]
	end

	def asap!
		@asap = true
	end

	def asap= value
		@asap = !!value
	end

	class << self
		def max_date
			@max_date ||= Time.now + 10.years
		end

		def min_date
			@min_date ||= Time.now
		end

		def max_date= date
			@max_date = date if valid_date?(date)
		end

		def min_date= date
			@max_date = date if valid_date?(date)
		end

		def asap options = {}
			self.new options.merge(asap: true)
		end

		def from start, duration, options = {}
			asap = false
			start = case start.to_sym
			when :now, :asap
				asap = true
				Time.now
			when :today
				Date.today
			when :tomorrow
				Date.today + 1.day
			when :next_week # requires active_support
				date = Date.today.next_week
				options[:start] ? date.beginning_of_week : date
			when :next_month			
				date = Date.today.next_month
				options[:start] ? date.at_beginning_of_month.next_month : date
			else
				start
			end

			self.new start_date: start, duration: duration, asap: asap
		end

		def untill ending
			ending = case ending.to_sym
			when :tomorrow
				Date.today + 1.day
			when :next_week # requires active_support
				date = Date.today.next_week
				options[:start] ? date.beginning_of_week : date
			when :next_month			
				date = Date.today.next_month
				options[:start] ? date.at_beginning_of_month.next_month : date
			else
				ending
			end
			self.new start_date: Date.now, end_date: ending
		end
		alias_method :until, :untill

		protected

		def valid_date? date
			date.any_kind_of?(Date, Time, DateTime)
		end
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

	def asap?
		!!@asap
	end

	def min
		asap? ? Time.now : start_time
	end

	def max
		end_time
	end

	def untill time
		self.end_time =	time
		self
	end
	alias_method :until, :untill

	def convert_to_time time
		time = Duration.new time if time.kind_of? Numeric				 
		case time
		when String
			Chronic.parse(time)
		when Date, DateTime
			time.to_time
		when Duration
			(Time.now + time).to_time
		when Time
			time
		else
			raise ArgumentError, "A valid time must be one of #{valid_time_classes.inspect}, was: #{time.inspect} (#{time.class})"
		end
	end

	protected

	def valid_time_classes
		[String, Duration, Date, Time, DateTime]
	end

	attr_reader :init_options

	def first_from keys, options = {}
		keys.select {|key| options[key] }.first
	end

	# uses init_options to configure
	def configure! options = {}
		from 	= options[first_from(START_KEYS, options)]
		to 		= options[first_from(END_KEYS, options)]
		dur 	= options[first_from(DURATION_KEYS, options)]
		asap  = options[:asap]

		if options[:at_least]
			to = Timespan.max_date 
			from = Time.now + options[:at_least]
		end

		if options[:at_most]
			to   = Time.now + options[:at_most]
			from = Time.now
		end

		if options[:between]
			from = Time.now + options[:between].min
			to = Time.now + options[:between].max
		end

		# puts "configure: to:#{to}, from:#{from}, dur:#{dur}, asap:#{asap}"

		@asap 						= asap if asap
		self.duration 		= dur if dur
		self.start_time 	= from if from
		self.end_time 		= to if to

		# puts "configured: start:#{self.start_time}, end:#{self.end_time}, duration:#{self.duration}, asap:#{self.asap?}"

		default_from_now!
		calculate_miss!
	rescue ArgumentError => e
		raise TimeParseError, e.message
	# rescue Exception => e
	# 	puts "Exception: #{e}"
	# 	calculate_miss!
	# 	validate!
	end		

	def default_from_now!
		self.start_time = now unless start_time || (end_time && duration)
		self.end_time = now unless end_time || (start_time && duration)
	end

	def now
		Time.now.utc
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
		self.end_time = start_time + duration.total
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