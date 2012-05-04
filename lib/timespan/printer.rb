class Timespan
	class << self
		attr_writer :time_format

		def time_format
			@time_format ||= "%d %b %Y"
		end
	end

	module Printer
		# locale-dependent terminology
		# %~s, %~m, %~h, %~d and %~w
		#
		# %td  => total days
  	# %th  => total hours
  	# %tm  => total minutes
  	# %ts  => total seconds
		def to_s mode = :full
			meth = "print_#{mode}"
			raise ArgumentError, "Print mode not supported, was: #{mode}" unless respond_to?(meth)
			send(meth)
		end

		def print_dates
			"#{i18n_t 'from'} #{print :start_time} #{i18n_t 'to'} #{print :end_time}"
		end

		def print_duration
			print :duration
		end

		def print_full
			 [print_dates, i18n_t('lasting'), print_duration].join(' ')
		end

		protected

		def i18n_t label
			I18n.t(label, :scope => :timespan, :default => label.to_s)
		end

		def print type
			return duration.format(duration_format) if type == :duration
			raise ArgumentError, "Not a valid print type, was: #{type}" unless valid_print_type? type
			send(type).strftime(time_format)
		end
	
		def valid_print_type? type
			%w{start_time end_time}.include? type.to_s
		end

		def time_format
			Timespan.time_format
		end

		def duration_format
			identifiers = []
			identifiers << 'y' if (duration.years > 0)
			identifiers << 'o' if (duration.months > 0)
			identifiers << 'w' if (duration.weeks > 0)
			identifiers << 'd' if (duration.days > 0)
			identifiers << 'h' if (duration.hours > 0)
			identifiers << 'm' if (duration.minutes > 0)
			identifiers << 's' if (duration.seconds > 0)

			identifiers.map {|id| "%#{id} %~#{id}" }.join(' ')
		end
	end
end