module Amorail
  # AmoCRM custom field entity
  class CustomField < Amorail::BaseEntity
    # --- Entity name
    amo_entity_endpoint 'fields'

    # --- Attributes
    amo_attribute :name
    amo_attribute :field_type
    amo_attribute :element_type
    amo_attribute :origin
    amo_attribute :is_editable
    amo_attribute :enums
    amo_attribute :is_required
    amo_attribute :is_deletable
    amo_attribute :is_visible

    # --- Class methods

    def self.all
      # HACK: As long as there are no API endpoint for retrieve all custom fields for account,
      # we need to use Amorail.properties to get fields from it.
      #
      # TODO: Finish with this method

      raise NotImplementedError
    end

    def self.find(id)
      # HACK: As long as there are no API endpoint for retrieve all custom fields for account,
      # we need to use Amorail.properties to get fields from it.
      #
      # TODO: Finish with this method

      raise NotImplementedError
    end

    def self.find_by_query(q)
      raise NotImplementedError
    end
  end
end