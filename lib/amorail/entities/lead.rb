module Amorail
  # AmoCRM lead entity
  class Lead < Amorail::BaseEntity
    include Taggable

    # --- Constants
    AMO_ENTITY_CODE = 2

    # --- Entity name
    amo_entity_endpoint 'leads'

    # --- Attributes
    amo_attribute :name
    amo_attribute :sale
    amo_attribute :status_id # TODO: Remove
    amo_attribute :pipeline_id # TODO: Remove

    # --- Relations
    amo_has_many :contacts, as_array: true
    amo_has_many :notes, polymorphic: true
    amo_has_many :tasks, polymorphic: true

    amo_belongs_to :user
    amo_belongs_to :pipeline
    amo_belongs_to :status

    # --- Validations
    validates :name, presence: true
    validates :status_id, presence: true

    # --- Instance methods
  end
end
