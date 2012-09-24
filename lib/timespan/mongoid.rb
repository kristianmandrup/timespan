require "timespan"
require "mongoid/fields"
require "timespan/mongoid/timespanned"

# http://whytheluckystiff.net/articles/seeingMetaclassesClearly.html
class Object 
  def meta_def name, &blk
    (class << self; self; end).instance_eval { define_method name, &blk }
  end
end

module Mongoid
  module Fields
    class Timespan
      class << self
        attr_writer :start_field, :end_field

        def start_field
          @start_field || :from
        end

        def end_field
          @end_field || :to
        end
      end

      # protected

      module Methods
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

        def asap hash
          asap_value = hash['asap'] || hash[:asap]
          raise ArgumentError, ":asap is nil, #{hash.inspect}" if ![true, false, nil].include? asap_value
          asap_value
        end

        def serialize_time time
          raise ArgumentError, "Can't serialize time from nil" if time.nil?
          time.to_i
        end

        def deserialize_time millisecs
          raise ArgumentError, "Can't deserialize time from nil" if millisecs.nil?
          Time.at millisecs
        end      
      end

      include Methods
      extend Methods
    end
  end
end

if defined?(Mongoid::Fields) && Mongoid::Fields.respond_to?(:option)
  Mongoid::Fields.option :between do |model, field, options|  
    name = field.name.to_sym
    model.class_eval do
      meta_def :"#{name}_between" do |from, to|
        self.where(:"#{name}.#{TimeSpan.start_field}".gte => from.to_i, :"#{name}.#{TimeSpan.end_field}".lte => to.to_i)
      end
    end
  end
end

module Mongoid
  MAJOR_VERSION =  Mongoid::VERSION > '3' ? 3 : 2
end

require "timespan/mongoid/mongoid_#{Mongoid::MAJOR_VERSION}x"

TimeSpan = Mongoid::Fields::Timespan