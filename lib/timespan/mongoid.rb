require "timespan"
require "mongoid/fields"

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

if defined?(Mongoid::Fields) && Mongoid::Fields.respond_to? :option
  Mongoid::Fields.option :between do |model, field, options|  
    name = field.name.to_sym
    model.class_eval do
      meta_def :"#{name}_between" do |from, to|
        self.where(:"#{name}.#{TimeSpan.start_field}".gte => from.to_i, :"#{name}.#{TimeSpan.end_field}".lte => to.to_i)
      end
    end
  end
end

mongoid_version = Mongoid::VERSION > '3' ? 3 : 2
require "timespan/mongoid/mongoid_#{mongoid_version}x"

TimeSpan = Mongoid::Fields::Timespan