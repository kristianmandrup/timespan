class Timespan
  Serializer = Mongoid::Fields::Timespan

  # See http://mongoid.org/en/mongoid/docs/upgrading.html        

  # Serialize a Timespan or a Hash (with Timespan units) or a Duration in some form to
  # a BSON serializable type.
  #
  # @param [Timespan, Hash, Integer, String] value
  # @return [Hash] Timespan in seconds
  def mongoize
    {:from => Serializer.serialize_time(start_time), :to => Serializer.serialize_time(end_time), :duration => duration.total }
  end

  class << self
    # See http://mongoid.org/en/mongoid/docs/upgrading.html        

    # Serialize a Timespan or a Hash (with Timespan units) or a Duration in some form to
    # a BSON serializable type.
    #
    # @param [Timespan, Hash, Integer, String] value
    # @return [Hash] Timespan in seconds
    def mongoize object
      case object
      when Timespan then object.mongoize
      when Hash
        ::Timespan.new object
      else
        object
      end
    end

    # Deserialize a Timespan given the hash stored by Mongodb
    #
    # @param [Hash] Timespan as hash
    # @return [Timespan] deserialized Timespan
    def demongoize(object)
      return if !object
      case object
      when Hash
        ::Timespan.new :from => Serializer.from(object), :to => Serializer.to(object)
      else
        ::Timespan.new object
      end        
    end

    # Converts the object that was supplied to a criteria and converts it
    # into a database friendly form.
    def evolve(object)
      case object
      when Timespan then object.mongoize
      else object
      end
    end
  end
end
