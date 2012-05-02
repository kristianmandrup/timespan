class Timespan
	module UnitConverter
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
	end
end