require 'origin-selectable_ext'
require 'timespan/core_ext/hash'

class Timespan
  Serializer = Mongoid::Fields::Timespan

  def __evolve_to_timespan__
    self
  end


  # See http://mongoid.org/en/mongoid/docs/upgrading.html        

  # Serialize a Timespan or a Hash (with Timespan units) or a Duration in some form to
  # a BSON serializable type.
  #
  # @param [Timespan, Hash, Integer, String] value
  # @return [Hash] Timespan in seconds
  def mongoize
    hash = { 
      :from => Serializer.serialize_time(start_time), 
      :to => Serializer.serialize_time(end_time), 
      :duration => duration.total, 
      :asap => asap? 
    }
    # puts "serialize: #{hash}"
    hash
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
        object.__evolve_to_timespan__
      else
        ::Timespan.new object
      end        
    end

    # Converts the object that was supplied to a criteria and converts it
    # into a database friendly form.
    def evolve(object)
      object.__evolve_to_timespan__.mongoize
    end

    def custom_serialization?(operator)
      return false unless operator
      case operator
        when '$gte', '$gt', '$lt', '$lte', '$eq', '$between', '$btw'
          true
      else
        false
      end
    end

    def custom_specify(name, operator, value, options = {})
      # puts "custom_specify: #{name}"
      timespan = value.__evolve_to_timespan__
      case operator
        when '$gte', '$gt', '$lt', '$lte', '$eq', '$between', '$btw'
          specify_with_asap(name, operator, timespan, options)
      else
        raise RuntimeError, "Unsupported operator"
      end
    end

    def specify_with_asap(name, operator, timespan, options)
      query = { 'from' => {}, 'to' => {} }
      case operator      
      when '$gte', '$gt'
        query['from'][operator] = Serializer.serialize_time(timespan.min)
      when '$lte', '$lt', '$eq'
        query['to'][operator] = Serializer.serialize_time(timespan.min)
      when '$between', '$btw'
        query['from']['$gte'] = Serializer.serialize_time(timespan.min)
        query['to']['$lte'] = Serializer.serialize_time(timespan.max)
      end
      # puts "query: #{query}"
      query
    end
  end
end
