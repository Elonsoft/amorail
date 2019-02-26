module Amorail
  class PipelineStatus < Amorail::BaseEntity
    # --- Attributes
    amo_attribute :name
    amo_attribute :pipeline_id # TODO: Remove
    amo_attribute :sort
    amo_attribute :color
    amo_attribute :is_editable
    amo_attribute :type

    # --- Relations
    amo_belongs_to :pipeline
  end
end