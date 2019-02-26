module Amorail
  module Taggable
    extend ActiveSupport::Concern

    included do
      amo_attribute :tags, :serialized_array

      def merge_attributes(attributes)
        super(attributes)

        self.tags = (attributes['tags'] || []).map do |t|
          t.is_a?(Hash) ? t['name'] : t
        end

        self
      end
    end
  end
end