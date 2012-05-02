require 'duration'
require 'chronic'
require 'chronic_duration'
require 'spanner'

require 'timespan/unit_converter'
require 'timespan/compare'
require 'timespan/printer'
require 'timespan/span'


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
		set_end_time		
		set_start_time		
		set_duration		
		set_end_time	
		set_start_time
	end

	def set_end_time
		self.end_time 	= start_time 	- duration.total 	if missing_end_time?
	end

	def set_start_time
		self.start_time = end_time 		- duration.total 	if missing_start_time?
	end

	def set_duration
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