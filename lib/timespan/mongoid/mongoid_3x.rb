class Timespan
  module Mongoize
    extend ActiveSupport::Concern
    # See http://mongoid.org/en/mongoid/docs/upgrading.html        

    # Serialize a Timespan or a Hash (with Timespan units) or a Duration in some form to
    # a BSON serializable type.
    #
    # @param [Timespan, Hash, Integer, String] value
    # @return [Hash] Timespan in seconds
    def mongoize
      {:from => serialize_time(start_time), :to => serialize_time(end_time), :duration => duration.total }
    end

    module ClassMethods
      # Deserialize a Timespan given the hash stored by Mongodb
      #
      # @param [Hash] Timespan as hash
      # @return [Timespan] deserialized Timespan
      def demongoize(value)
        return if !value
        case value
        when Hash
          ::Timespan.new :from => from(value), :to => to(value)
        else
          ::Timespan.new value
        end        
      end

      # TODO
      # def evolve(object)
      #   { "$gte" => object.first, "$lte" => object.last }
      # end
    end
  end
end


class Timespan
  include Mongoize

  protected

  include Mongoid::Fields::Timespan::Methods
  extend Mongoid::Fields::Timespan::Methods
end
