require "timespan"
require "mongoid/fields"

# Mongoid serialization support for Timespan type.
module Mongoid
  module Fields
    class Timespan
      include Mongoid::Fields::Serializable
    
      def self.instantiate(name, options = {})
        super
      end

      # Deserialize a Timespan given the hash stored by Mongodb
      #
      # @param [Hash] Timespan as hash
      # @return [Timespan] deserialized Timespan
      def deserialize(timespan_hash)
        return if !timespan_hash
        ::Timespan.new(:from => timespan_hash[:from], :to => timespan_hash[:to])
      end

      # Serialize a Timespan or a Hash (with Timespan units) or a Duration in some form to
      # a BSON serializable type.
      #
      # @param [Timespan, Hash, Integer, String] value
      # @return [Hash] Timespan in seconds
      def serialize(value)
        return if value.blank?
        timespan = ::Timespan.new(value)
        {:from => timespan.start_time, :to => timespan.end_time, :duration => timespan.duration.total}
      end
    end
  end
end

TimeSpan = Mongoid::Fields::Timespan