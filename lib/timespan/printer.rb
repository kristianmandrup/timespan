class Timespan
	module Printer
		def to_s
			if duration
				"Timespan: from #{start_time} lasting #{duration} = #{seconds} secs" if start_time
				"Timespan: from #{end_time} to #{duration} before = #{seconds} secs" if end_time
				return
			end

			if start_time && end_time
				"Timespan: #{start_time} to #{end_time} = #{seconds} secs"			
				return
			end

			if seconds
				"Timespan: #{seconds} seconds"
			end
		end
	end
end