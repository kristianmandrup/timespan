require 'time-lord'

class Timespan
  def duration_classes
    [::TimeLord::Period, ::Duration, ::String]
  end

  def valid_time_classes
    [String, Duration, Date, Time, DateTime, TimeLord::Period, TimeLord::Time]
  end

  def convert_to_time time
    time = Duration.new time if time.kind_of? Numeric        
    case time
    when String
      Chronic.parse(time)
    when Date, DateTime
      time.to_time
    when Duration
      (Time.now + time).to_time
    when TimeLord::Period
      (Time.now + time).to_time
    when TimeLord::Time
      (Time.now + time.moment).to_time
    when Time
      time
    else
      raise ArgumentError, "A valid time must be one of #{valid_time_classes.inspect}, was: #{time.inspect} (#{time.class})"
    end
  end

  module Compare
    def <=> time
      raise ArgumentError, "Not a valid argument for Timespan comparison, was #{time}" unless valid_compare?(time)
      case time
      when Timespan
        seconds <=> time.seconds
      when Time     
        seconds <=> time.to_i
      when Date, DateTime
        time.to_time.to_i
      when Integer
        seconds <=> time
      when Timelord::Time
        seconds <=> time.moment
      when ActiveSupport::Duration
        seconds <=> time.to_i
      end
    end
  end

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
  end
end