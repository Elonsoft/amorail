module Amorail
  # AmoCRM task entity
  class Task < Amorail::BaseEntity
    # --- Constants
    AMO_ENTITY_CODE = 4
    PREDEFINED_TASK_TYPES = { call: 1, meeting: 2, email: 3 }.freeze

    # --- Entity name
    amo_entity_endpoint 'tasks'

    # --- Attributes
    amo_attribute :task_type
    amo_attribute :text
    amo_attribute :is_completed
    amo_attribute :complete_till, type: :timestamp

    # --- Relations
    amo_belongs_to :element, polymorphic_to: ['Amorail::Company', 'Amorail::Contact', 'Amorail::Lead']

    # --- Validations
    validates :task_type, presence: true
    validates :text, presence: true
    validates :complete_till, presence: true

    # validates :task_type, inclusion: { in: lambda { allowed_task_types } }

    # --- Instance methods

    def allowed_task_types
      PREDEFINED_TASK_TYPES
    end
  end
end
