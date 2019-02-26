module Amorail
  module Entities
    module Persistence
      extend ActiveSupport::Concern

      class_methods do
        def create(attributes)
          instance = new(attributes)
          instance.save
        end

        def create!(attributes)
          create(attributes) || fail(InvalidRecord)
        end
      end

      def new_record?
        id.blank?
      end

      def persisted?
        !new_record?
      end

      def save
        return false if self.class.readonly?
        return false unless valid?

        if new_record?
          push_to_api_with('create')
        else
          push_to_api_with('update')
        end
      end

      def save!
        save || fail(InvalidRecord)
      end

      def update(attributes = {})
        return false if self.class.readonly?
        return false unless valid?

        attributes.each_pair do |key, value|
          public_send("#{key}=".to_sym, value) if self.class.attributes.keys.include?(key)
        end

        return save if new_record?

        push_to_api_with('update') ? true : false
      end

      def update!(attributes = {})
        update(attributes) || fail(NotPersisted)
      end

      def reload
        fail(NotPersisted) if id.nil?

        self.class.find(id)
      end

      private

      def extract_data_on_create(response)
        response['items'].first
      end

      # Update response in amoCRM may have status 200 and contain errors.
      # In case of errors "update" key in a response is a Hash with "errors" key.
      # If there are no errors "update" key is an Array with entities attributes.
      def extract_data_on_update(response)
        if response['items'].empty?
          merge_errors(response.dig('errors', 'update'))
          raise(InvalidRecord)
        end

        response['items'].first
      end

      def merge_errors(data)
        data.each do |_, message|
          errors.add(:base, message)
        end
      end
    end
  end
end
