module Amorail
  class Property
    module MethodMissing
      def method_missing(method_sym, *arguments, &block)
        if data.key?(method_sym.to_s)
          data.fetch(method_sym.to_s)
        else
          super
        end
      end

      def respond_to_missing?(method_sym, *args)
        args.size.zero? && data.key?(method_sym.to_s)
      end
    end

    class PropertyItem
      include MethodMissing

      class << self
        attr_accessor :source_name

        def parse(data)
          hash = {}
          data['custom_fields'].fetch(source_name, []).each do |contact|
            identifier = contact['code'].presence || contact['name'].presence
            next if identifier.nil?

            hash[identifier.downcase] = PropertyItem.new(contact)
          end
          new hash
        end
      end

      attr_reader :data

      def initialize(data)
        @data = data
      end

      def [](key)
        @data[key]
      end
    end
  end
end
