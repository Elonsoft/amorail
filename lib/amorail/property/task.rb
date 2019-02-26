module Amorail
  class Property
    class Task < PropertyItem
      def self.parse(data)
        hash = {}
        data.fetch('task_types', []).each do |task_type|
          property_item = PropertyItem.new(task_type)
          identifier = task_type['code'].presence || task_type['name'].presence
          next if identifier.nil?

          hash[identifier.downcase] = property_item
          hash[identifier] = property_item
        end
        new hash
      end
    end
  end
end