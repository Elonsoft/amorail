module Amorail
  class PipelineStatus < Amorail::BaseEntity
    # --- Attributes
    amo_attribute :name
    amo_attribute :sort
    amo_attribute :color
    amo_attribute :is_editable
  end
end