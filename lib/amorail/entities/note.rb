module Amorail
  # AmoCRM note entity
  class Note < Amorail::BaseEntity
    # --- Entity name
    amo_entity_endpoint 'notes'

    # --- Attributes
    amo_attribute :note_type
    amo_attribute :text
    amo_attribute :element_id # TODO: Remove
    amo_attribute :element_type # TODO: Remove

    # --- Relations
    amo_belongs_to :element, polymorphic_to: [
      'Amorail::Company', 'Amorail::Contact', 'Amorail::Lead', 'Amorail::Task'
    ]

    # --- Validations
    validates :element_id, presence: true
    validates :element_type, presence: true
    validates :note_type, presence: true
    validates :text, presence: true
    # validates :element_type, inclusion: ELEMENT_TYPES.values
  end
end
