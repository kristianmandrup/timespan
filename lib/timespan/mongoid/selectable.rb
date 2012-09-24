# encoding: utf-8

## Extracted from @nessche monkey-patch for use with mongoid-money
module Origin

  # An origin selectable is selectable, in that it has the ability to select
  # document from the database. The selectable module brings all functionality
  # to the selectable that has to do with building MongoDB selectors.
  module Selectable

    private

    # Create the standard expression query.
    #
    # @api private
    #
    # @example Create the selection.
    #   selectable.expr_query(age: 50)
    #
    # @param [ Hash ] criterion The field/value pairs.
    #
    # @return [ Selectable ] The cloned selectable.
    #
    # @since 1.0.0
    def expr_query(criterion)
      selection(criterion) do |selector, field, value|
        if (field.is_a? Key) && custom_serialization?(field.name, field.operator)
          specified = custom_specify(field.name, field.operator, value)
        else
          specified = field.specify(value.__expand_complex__, negating?)
        end
        selector.merge!(specified)
      end
    end

    def between(criterion = nil)
      selection(criterion) do |selector, field, value|
        expr = custom_between?(field, value) ? custom_between(field, value) : { "$gte" => value.min, "$lte" => value.max }
        selector.store(
          field, expr
        )
      end
    end    

    def custom_between? name, value
      serializer = @serializers[name.to_s]
      serializer && serializer.type.respond_to?(:custom_between?) && serializer.type.custom_between?(name, value)
    end    

    def custom_between(name, value)
      serializer = @serializers[name.to_s]
      raise RuntimeError, "No Serializer found for field #{name}" unless serializer
      serializer.type.custom_between(name, value, serializer.options)
    end    

    def custom_serialization?(name, operator)
      serializer = @serializers[name.to_s]
      serializer && serializer.type.respond_to?(:custom_serialization?) && serializer.type.custom_serialization?(operator)
    end

    def custom_specify(name, operator, value)
      serializer = @serializers[name.to_s]
      raise RuntimeError, "No Serializer found for field #{name}" unless serializer
      serializer.type.custom_specify(name, operator, value, serializer.options)
    end
  end
end