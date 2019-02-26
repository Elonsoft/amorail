module Amorail
  # AmoCRM company entity
  class Company < Amorail::BaseEntity
    include Taggable

    # --- Constants
    AMO_ENTITY_CODE = 3

    # --- Entity name
    amo_entity_endpoint 'companies'

    # --- Attributes
    amo_attribute :name

    # --- Relations
    amo_has_many :leads
    amo_has_many :contacts, as_array: true
    amo_has_many :tasks, polymorphic: true
    amo_has_many :notes, polymorphic: true

    # --- Validations
    validates :name, presence: true
  end
end
