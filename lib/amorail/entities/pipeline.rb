module Amorail
  class Pipeline < Amorail::BaseEntity
    # --- Entity name
    amo_entity_endpoint 'pipelines', readonly: true

    # --- Attributes
    amo_attribute :name
    amo_attribute :sort
    amo_attribute :is_main
    amo_attribute :statuses

    # --- Instance methods

    def merge_attributes(attributes)
      # HACK: We need to do this magic because we're receive data from this endpoint as a hash
      # Example of the response:
      #
      # '1599685' => {
      #   'id' => 1_599_685,
      #   'value' => 1_599_685,
      #   'label' => '1. Покупатели',
      #   'name' => '1. Покупатели',
      #   'sort' => 1,
      #   'is_main' => true,
      #   'statuses' => {
      #     '24351241' => {
      #       'id' => 24_351_241,
      #       'name' => '1. незарегистрированный',
      #       'pipeline_id' => 1_599_685,
      #       'sort' => 20,
      #       'color' => '#d6eaff',
      #       'editable' => 'Y',
      #       'type' => 0
      #     },
      #     ...
      #   },
      #   'leads' => 1
      # },
      #
      # So there are two steps to normalize data:
      # 1. Take value of hash
      # 2. Transform statuses of pipeline to entities
      attributes = attributes[1]
      attributes['statuses'] = attributes['statuses'].values.map { |status| PipelineStatus.new(status) }
      super(attributes)
    end
  end
end