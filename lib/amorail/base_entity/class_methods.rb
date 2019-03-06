module Amorail
  module Entities
    module ClassMethods
      extend ActiveSupport::Concern

      class_methods do
        # Name of the entity in Amorail
        attr_reader :amo_name

        # Name of the entity in amoCRM (usually matches with .amo_name)
        attr_reader :amo_response_name

        # Is model readonly?
        attr_reader :readonly

        delegate :client, to: Amorail

        def inherited(subclass)
          subclass.amo_entity_endpoint(amo_name, response_name: amo_response_name)
        end

        def amo_entity_endpoint(name, response_name: nil, readonly: false)
          @amo_name = @amo_response_name = name
          @readonly = readonly
          @amo_response_name = response_name unless response_name.nil?
        end

        def readonly?
          @readonly
        end

        # Defines attributes for entity. Nowadays you have only :timestamp type for casting.
        #
        # Default untyped attributes are [ :id, :request_id, :responsible_user_id ]
        # Default attributes with :timestamp type are [ :created_at, :updated_at ]
        def amo_attribute(*name, type: :default)
          unless [Array, String, Symbol].any? {|klass| name.is_a?(klass)}
            raise TypeError, 'Only String, Symbol or Array allowed for name param'
          end

          unless [:default, :timestamp, :serialized_array].include?(type)
            raise TypeError, 'Only :default, :serialized_array or :timestamp allowed as type of attribute'
          end

          if name.is_a?(Array)
            name.each { |n| attributes[n] = type }
            attr_accessor(*name)
          else
            attributes[name] = type
            attr_accessor(name)
          end
        end

        def amo_custom_field(attribute_name, amo_name:, value_options: {})
          custom_fields[attribute_name] = {
            amo_name: amo_name.to_s.downcase,
            options: value_options
          }
          custom_fields_mapping[amo_name] = attribute_name

          attr_accessor(attribute_name)
        end

        def attributes
          @attributes ||= superclass.respond_to?(:attributes) ? superclass.attributes.dup : {}
        end

        def custom_fields
          @custom_fields ||= superclass.respond_to?(:custom_fields) ? superclass.custom_fields.dup : {}
        end

        def custom_fields_mapping
          @custom_fields_mapping ||= superclass.respond_to?(:custom_fields_mapping) ? superclass.custom_fields_mapping.dup : {}
        end
      end
    end
  end
end