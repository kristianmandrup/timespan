class Hash
  def __evolve_to_timespan__
    serializer = Mongoid::Fields::Timespan
    object = self
    # puts "evolve from: #{self}"
    ::Timespan.new :from => serializer.from(object), :to => serializer.to(object), asap: serializer.asap(object)
  end

  def __evolve_to_duration_range__
    range = Range.new (self['from'] || self[:from]), (self['to'] || self[:to])
    length = self['length'] || self[:length]
    clazz = case length.to_sym
    when :long 
      ::LongDurationRange
    when :short 
      ::ShortDurationRange
    else
      ::DurationRange
    end

    clazz.new range, (self['unit'] || self[:unit] || :seconds)
  end
end
