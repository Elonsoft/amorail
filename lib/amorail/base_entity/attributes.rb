module Amorail # :nodoc: all
  module Entities
    module Attributes
      extend ActiveSupport::Concern

      included do
        AMO_INTERNAL_METHOD_NAME = {
          create: 'add',
          update: 'update',
        }.freeze

        def assign_attributes(attrs = {})
          attrs.each_pair do |key, value|
            public_send("#{key}=".to_sym, value) if allowed_keys.include?(key.to_sym)
          end
        end

        def attributes
          data = {}

          # Iterate over class attributes and cast it to defined type.
          # TODO: Why we should iterate over attributes? Is there no another way to do this?
          self.class.attributes.each do |key, type|
            data[key] = send("to_#{type}", send(key))
          end
          data[:unlink] = build_removed_links.presence
          data[:custom_fields] = build_custom_fields if Amorail.properties.respond_to?(amo_name)

          normalize_params(data).compact
        end

        protected

        def build_custom_fields
          custom_fields_hash = Amorail.properties.send(self.class.amo_name)
          custom_fields = []

          # Iterate over custom fields and retrieve
          self.class.custom_fields.each do |attribute_name, attribute_options|
            custom_field_name = attribute_options[:amo_name] || attribute_name

            # Skip if there is no custom attribute
            next if custom_fields_hash[custom_field_name].nil?

            custom_field_id = custom_fields_hash[custom_field_name].id
            custom_field_enums = custom_fields_hash[custom_field_name]['enums']

            custom_field_value = {
              value: public_send(attribute_name),
              enum: custom_field_enums&.key(attribute_options[:options][:enum])
            }.compact
            custom_fields << { id: custom_field_id, values: [custom_field_value] }
          end

          custom_fields
        end

        def build_removed_links
          ids_to_remove = {}

          self.class.relations[:regular_has_many].keys.each do |relation_name|
            source_ids = instance_variable_get("@source_#{relation_name}_id") || []
            current_ids = instance_variable_get("@#{relation_name}_id") || []
            diff = source_ids - current_ids
            ids_to_remove["#{relation_name}_id"] = diff if diff.count.positive?
          end

          ids_to_remove
        end

        # TODO: Describe what happens here.
        def prepare_params_for_api_request(method)
          {
            AMO_INTERNAL_METHOD_NAME.fetch(method.to_sym) => [attributes]
          }
        end

        # This method transforms raw params by removing keys with empty values (nil, [], etc).
        # Returns ready-to-make-request hash of entity params.
        def normalize_params(raw_params)
          return raw_params unless raw_params.is_a?(Hash)

          normalized_params = {}
          raw_params.each do |key, value|
            case value
            when Numeric, String
              normalized_params[key] = value
            when Array
              compact_array = value.compact
              compact_array = normalize_custom_fields(compact_array) if key == :custom_fields
              normalized_params[key] = compact_array.map { |el| normalize_params(el) } unless compact_array.empty?
            else
              params = normalize_params(value)
              normalized_params[key] = params unless params.nil?
            end
          end

          normalized_params.with_indifferent_access
        end

        # What is normalize? Why we should do this?
        def normalize_custom_fields(val)
          val.reject do |field|
            field[:values].all? { |item| !item[:value] }
          end
        end

        def to_timestamp(value)
          return if value.nil?

          case value
          when String
            (date = Time.parse(value)) && date.to_i
          when Date
            value.to_time.to_i
          else
            value.to_i
          end
        end

        def to_serialized_array(value)
          return if value.presence.nil?

          value.join(', ')
        end

        def to_default(value)
          value
        end
      end
    end
  end
end
