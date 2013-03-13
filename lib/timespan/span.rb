class Timespan
	class DurationParseError < StandardError; end

	module Span
		attr_reader :duration

		def duration= duration
			@duration = if duration.kind_of? Numeric
				 Duration.new duration
			else
				case duration
				when Timespan
					duration.duration
				when Duration
					duration
				when TimeLord::Period
					Duration.new start_date: duration.beginning, end_date: duration.ending
				when Hash
					Duration.new duration
				when String
					Duration.new parse_duration(duration)
				else
					raise ArgumentError, "Unsupported duration type: #{duration.inspect} of class #{duration.class}"
				end	
			end
			unless is_new?
				add_dirty :duration
				refresh!
				calculate!
			end
		end

		protected

		def parse_duration text
			spanner_parse text
		rescue Spanner::ParseError => e
			chronic_parse text
		rescue ChronicDuration::DurationParseError => e
			raise Timespan::DurationParseError, "Internal error: neither Spanner or ChronicDuration could parse '#{duration}'"
		end

		def spanner_parse text
			Spanner.parse(text.gsub /and/, '')
		end

		def chronic_parse text
			ChronicDuration.parse text
		end
	end
end