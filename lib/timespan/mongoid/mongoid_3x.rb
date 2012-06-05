# Mongoid serialization support for Timespan type.
module Mongoid
  module Fields
    class Timespan
      # Deserialize a Timespan given the hash stored by Mongodb
      #
      # @param [Hash] Timespan as hash
      # @return [Timespan] deserialized Timespan
      def demongoize(value)
        return if !value
        ::Timespan.new :from => from(value), :to => to(value)
      end

      # Serialize a Timespan or a Hash (with Timespan units) or a Duration in some form to
      # a BSON serializable type.
      #
      # @param [Timespan, Hash, Integer, String] value
      # @return [Hash] Timespan in seconds
      def mongoize(value)
        return if value.blank?
        timespan = case value
        when ::Timespan
          value
        else
          ::Timespan.new(value)
        end
        {:from => serialize_time(timespan.start_time), :to => serialize_time(timespan.end_time.to_i), :duration => timespan.duration.total }
      end
    end
  end
end