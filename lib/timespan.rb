require 'duration'
require 'chronic_duration'
require 'spanner'

require 'timespan/compare'
require 'timespan/printer'
require 'timespan/span'
require 'timespan/unit_converter'

class Timespan
	include Span
	include Printer
	include Compare
	include UnitConverter

	class TimeParseError < StandardError; end	

	attr_reader :start_time, :end_time

	alias_method :start_date, :start_time
	alias_method :end_date, 	:end_time

	def initialize options = {}
		@is_new = true

		configure options		
		
		@is_new = false
	end

	def start_time= time
		@start_time = convert_to_time time
		refresh!
	end
	alias_method :start_date=, :start_time=

	def end_time= time
		@end_time = convert_to_time time
		refresh!
	end
	alias_method :end_date=, :end_time=

	def seconds
		@seconds 	||= duration.total
	end
		
	alias_method :to_secs, 		:seconds
	alias_method :to_seconds, :seconds

	def convert_to_time time
		case time
		when String
			Chronic.parse(time)
		when Date, Time, DateTime
			time
		else
			raise ArgumentError, "A valid time must be either a String, Date, Time or DateTime, was: #{time.inspect}"
		end
	end

	protected

	def configure options = {}		
		from 	= options[:from] || options[:start]
		to 		= options[:to] || options[:end]

		self.duration 		= options[:duration] if options[:duration]
		self.start_time 	= from if from
		self.end_time 		= to if to		
	rescue Exception => e
		calculate!
		validate!
	end		

	def validate!	
		raise ArgumentError, "#{valid_requirement}, was: #{current_config}" unless valid?
	end

	def valid_requirement
		"Timespan must take a :start and :end time or any of :start and :end time and a :duration"
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

	def calculate!		
		self.end_time 	= start_time 	- duration.total 	if missing_end_time?
		self.start_time = end_time 		- duration.total 	if missing_start_time?
		self.duration 	= end_time 		- start_time 			if missing_duration?
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
		calculate!
		units.each do |unit| 
			var_name = :"@#{unit}"
			instance_variable_set var_name, nil
		end
	end
end