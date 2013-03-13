class TimespanRange < DelegateDecorator
  attr_accessor :unit, :range

  def initialize range, unit = :minutes
    range = (0..60) if range.min == nil || range.max == nil
    super(range, except: %w{to_s to_str})
    @range = Timespan.new between: range
    @unit = unit.to_s.pluralize.to_sym
  end

  def to_str
    to_s
  end

  def to_s
    range.min.nil? ? 'no timespan range' : "#{range.min} to #{range.max} #{unit}"
  end
end

class DurationRange < DelegateDecorator
  include Comparable

  attr_accessor :unit, :range

  def initialize range, unit = :minutes
    range = (0..60) if range.min == nil || range.max == nil  
    super(range, except: %w{to_s to_str})
    unit = unit.to_s.pluralize.to_sym

    unless allowed_unit? unit
      raise ArgumentError, "Unit #{unit} not valid, only: #{allowed_units} are valid" 
    end

    @unit = unit
    
    @range = range
  end

  alias_method :units, :unit

  def <=> other_dur_range
    min_secs = self.min
    max_secs = self.max
    omin_secs = other_dur_range.min
    omax_secs = other_dur_range.max

    # puts "self: #{self.inspect} vs #{other_dur_range.inspect} #{other_dur_range.class}"

    if min_secs == omin_secs && max_secs == omax_secs
      return 0
    end

    if min_secs < omin_secs || (min_secs == omin_secs && max_secs < omax_secs) 
      -1
    else
      1
    end
  end

  def length
    :default
  end

  def self.allowed_unit? unit
    allowed_units.include? unit.to_sym
  end

  def allowed_unit? unit
    allowed_units.include? unit.to_sym
  end

  def allowed_units
    [:seconds, :minutes, :hours, :days, :weeks, :months, :years]
  end

  def to_str
    to_s
  end

  def to_s
    range.min.nil? ? 'no duration range' : "#{range.min} to #{range.max} #{unit}"
  end

  def time
    min == max ? "#{min} #{unit.to_s.singularize}" : "#{min}-#{max} #{unit}"
  end

  def between? duration
    obj = case duration
    when Duration
      duration
    else
      Duration.new duration
    end
    obj.total >= min && obj.total <= max
  end

  def to_hash
    {:from => range.min.to_i, :to => range.max.to_i, unit: unit.to_s, length: length.to_s}
  end

  def mongoize
    to_hash
  end

  protected

  def __evolve_to_duration_range__
    self
  end

  class << self
    # See http://mongoid.org/en/mongoid/docs/upgrading.html        

    # Serialize a Hash (with DurationRange keys) or a DurationRange to
    # a BSON serializable type.
    #
    # @param [Timespan, Hash, Integer, String] value
    # @return [Hash] Timespan in seconds
    def mongoize object
      mongoized = case object
      when DurationRange then object.mongoize
      when Hash
        object
      when Range
        object.send(:seconds).mongoize
      else
        object
      end
      # puts "mongoized: #{mongoized} - Hash"
      mongoized
    end

    # Deserialize a Timespan given the hash stored by Mongodb
    #
    # @param [Hash] Timespan as hash
    # @return [Timespan] deserialized Timespan
    def demongoize(object)
      return if !object
      
      demongoized = case object
      when Hash
        object.__evolve_to_duration_range__
      when Range
        object.__evolve_to_duration_range__
      else
        raise "Unable to demongoize DurationRange from: #{object}"
      end    
      # puts "demongoized: #{demongoized} - #{demongoized.class}"
      demongoized
    end

    # Converts the object that was supplied to a criteria and converts it
    # into a database friendly form.
    def evolve(object)
      object.__evolve_to_duration_range__.mongoize
    end 

    protected

    def parse duration
      if duration.kind_of? Numeric
         return Duration.new duration
      else
        case duration
        when Timespan
          duration.duration
        when Duration
          duration
        when Hash
          Duration.new duration
        when Time
          duration.to_i
        when DateTime, Date
          duration.to_time.to_i
        when String
          Duration.new parse_duration(duration)
        else
          raise ArgumentError, "Unsupported duration type: #{duration.inspect} of class #{duration.class}"
        end 
      end
    end
  end 
end

class LongDurationRange < DurationRange
  def length
    :long
  end

  def self.allowed_units
    [:days, :weeks, :months, :years]
  end

  def allowed_units
    LongDurationRange.allowed_units
  end
end

class ShortDurationRange < DurationRange
  def length
    :short
  end

  def self.allowed_units
    [:seconds, :minutes, :hours]
  end

  def allowed_units
    ShortDurationRange.allowed_units
  end
end

class Range
  def __evolve_to_duration_range__
    ::DurationRange.new self, :seconds
  end    

  [:seconds, :minutes, :hours, :days, :weeks, :months, :years].each do |unit|
    define_method "#{unit}!" do
      time_length = ::ShortDurationRange.allowed_unit?(unit.to_sym) ? :short : :long
      self.send(unit, time_length)
    end

    define_method unit do |type = :duration, subtype = nil|
      timerange = Range.new self.min.send(unit), self.max.send(unit)

      subtype = type if [:long, :short].include? type.to_sym

      if type != :timespan
        time_range_class = if ::ShortDurationRange.allowed_unit? unit.to_sym
          subtype == :short ? ::ShortDurationRange : ::DurationRange
        elsif ::LongDurationRange.allowed_unit? unit.to_sym
          subtype == :long  ? ::LongDurationRange : ::DurationRange
        else
          ::DurationRange
        end
      end

      type == :timespan ? TimespanRange.new(timerange, unit) : time_range_class.new(timerange, unit)
    end
  end
end