module Amorail
  # Base class for all entities in library.
  #
  # Defines basic attributes of all entities such as
  # :id, :request_id, :responsible_user_id, :created_at, :updated_at
  class BaseEntity
    # Includes
    include ActiveModel::Model
    include ActiveModel::Validations

    include Amorail::Entities::Attributes
    include Amorail::Entities::ClassMethods
    include Amorail::Entities::Finders
    include Amorail::Entities::Persistence
    include Amorail::Entities::Relations

    # Default attributes for any entity
    amo_attribute :id
    amo_attribute :request_id
    amo_attribute :responsible_user_id
    amo_attribute :created_at, type: :timestamp
    amo_attribute :updated_at, type: :timestamp

    delegate :amo_name, :client, to: :class

    delegate :custom_fields, to: Amorail

    def initialize(attributes = {})
      super(attributes)
    end

    def merge_attributes(attributes)
      attributes = transform_related_entities(attributes)
      assign_known_attributes(attributes)
      assign_custom_fields(attributes['custom_fields'])
      self
    end

    private

    def transform_related_entities(attributes)
      related_entities = self.class.relations[:regular_has_many].keys
      related_entities.each do |entity_name|
        next unless attributes.has_key?(entity_name.to_s) || attributes.has_key?("#{entity_name}_id")

        ids = attributes.dig(entity_name.to_s, 'id') || attributes["#{entity_name}_id"] || []
        instance_variable_set("@source_#{entity_name}_id", ids)
        attributes["#{entity_name}_id"] = ids
      end
      attributes.except(*related_entities)
    end

    def assign_known_attributes(attributes)
      known_attributes = self.class.attributes.keys.map(&:to_s)
      attributes.
        transform_keys(&:to_s).
        slice(*known_attributes).
        each_pair { |key, value| send("#{key}=", value) }
    end

    def assign_custom_fields(fields)
      return if fields.nil?

      fields.each do |field|
        field_name = field['code'] || field['name']
        next if field_name.nil?

        field_name = "#{field_name.downcase}="

        field_value = field.fetch('values').first.fetch('value')
        send(field_name, field_value) if respond_to?(field_name)
      end
    end

    # Sends request to API using safe method that will authorize if
    # the current session is undefined or expired.
    # Move to persistence layer
    def push_to_api_with(method)
      prepared_params = prepare_params_for_api_request(method)
      response = commit_request_to_api(prepared_params)
      handle_response(method, response)
    end

    # Move to persistence layer
    def commit_request_to_api(attributes)
      client.safe_request(:post, amo_name, normalize_params(attributes))
    end

    # We can have response with 200 or 204 here.
    # 204 response has no body, so we don't want to parse it.
    def handle_response(method, response)
      return false if response.status == 204

      data = send(
        "extract_data_on_#{method}",
        response.body['_embedded']
      )

      relations = self.class.relations[:regular_has_many].keys
      old_attributes = attributes
      relations.each do |relation_name|
        instance_variable_set("@source_#{relation_name}_id", old_attributes["#{relation_name}_id"] || [])
      end
      merge_attributes(old_attributes.merge(data))
    rescue InvalidRecord
      false
    end
  end
end
