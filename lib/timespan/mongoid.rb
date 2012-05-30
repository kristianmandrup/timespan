require "timespan"
require "mongoid/fields"

# http://whytheluckystiff.net/articles/seeingMetaclassesClearly.html
class Object 
  def meta_def name, &blk
    (class << self; self; end).instance_eval { define_method name, &blk }
  end
end

Mongoid::Fields.option :between do |model, field, options|  
  name = field.name.to_sym
  model.class_eval do
    meta_def :"#{name}_between" do |from, to|
      self.where(:"#{name}.#{TimeSpan.start_field}".gte => from.to_i, :"#{name}.#{TimeSpan.end_field}".lte => to.to_i)
    end
  end
end

# Mongoid serialization support for Timespan type.
module Mongoid
  module Fields
    class Timespan
      include Mongoid::Fields::Serializable
    
      class << self
        attr_writer :start_field, :end_field

        def start_field
          @start_field || :from
        end

        def end_field
          @end_field || :to
        end
      end

      def self.instantiate(name, options = {})
        super
      end

      # Deserialize a Timespan given the hash stored by Mongodb
      #
      # @param [Hash] Timespan as hash
      # @return [Timespan] deserialized Timespan
      def deserialize(hash)
        return if !hash
        ::Timespan.new :from => from(hash), :to => to(hash)
      end

      # Serialize a Timespan or a Hash (with Timespan units) or a Duration in some form to
      # a BSON serializable type.
      #
      # @param [Timespan, Hash, Integer, String] value
      # @return [Hash] Timespan in seconds
      def serialize(value)
        return if value.blank?
        timespan = case value
        when ::Timespan
          value
        else
          ::Timespan.new(value)
        end
        {:from => serialize_time(timespan.start_time), :to => serialize_time(timespan.end_time.to_i), :duration => timespan.duration.total }
      end

      protected

      def from hash
        from_value = hash['from'] || hash[:from]
        raise ArgumentError, ":from is nil, #{hash.inspect}" if from_value.nil?
        deserialize_time from_value
      end

      def to hash
        to_value = hash['to'] || hash[:to]
        raise ArgumentError, ":to is nil, #{hash.inspect}" if to_value.nil?
        deserialize_time to_value
      end

      def serialize_time time
        time.to_i
      end

      def deserialize_time millisecs
        Time.at millisecs
      end
    end
  end
end

TimeSpan = Mongoid::Fields::Timespan