module Amorail
  class Property
    class Lead < PropertyItem
      self.source_name = 'leads'

      attr_accessor :statuses

      class << self
        def parse(data)
          object = super
          hash = {}
          data.fetch('leads_statuses', []).each do |property|
            hash[property['name']] = PropertyItem.new(property)
          end
          object.statuses = hash
          object
        end
      end
    end
  end
end