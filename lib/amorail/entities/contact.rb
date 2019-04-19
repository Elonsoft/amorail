module Amorail
  # AmoCRM contact entity
  class Contact < Amorail::BaseEntity
    include Taggable

    # --- Constants
    AMO_ENTITY_CODE = 1

    # --- Entity name
    amo_entity_endpoint 'contacts'

    # --- Attributes
    amo_attribute :name
    amo_attribute :company_name

    # --- Relations
    amo_has_many :leads, as_array: true
    amo_has_many :tasks, polymorphic: true
    amo_has_many :notes, polymorphic: true
    amo_belongs_to :company, optional: true, foreign_key: :company_id

    # --- Validations
    validates :name, presence: true
  end
end
