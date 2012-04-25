class TimeSpan
	attr_reader :start_time, :end_time, :millis

	def initialize start_time, end_time, options = {}
		@start_time = start_time
		@end_time 	= end_time

		@millis = start_time - end_time
	end

	def to_seconds
		@to_seconds ||= millis * 1000
	end
	alias_method :to_s, 	 :to_seconds
	alias_method :to_secs, :to_seconds

	def to_minutes
		@to_minutes ||= to_seconds * 60
	end
	alias_method :to_m, 		:to_minutes
	alias_method :to_mins, 	:to_minutes

	def to_hours
		@to_hours ||= to_minutes * 60
	end
	alias_method :to_h, :to_hours

	def to_days
		@to_days ||= to_hours * 24
	end	
	alias_method :to_d, :to_days

	def to_weeks
		@to_weeks ||= to_days * 7
	end	
	alias_method :to_w, :to_weeks

	def to_months
		@to_months ||= to_days * 30
	end	
	alias_method :to_mon, :to_months

	def to_years
		@to_years ||= (to_days.to_f * 365.25).round
	end	
	alias_method :to_y, :to_years
end