module Amorail # :nodoc: all
  module Entities
    module Finders
      extend ActiveSupport::Concern

      class_methods do
        # Loads single record from amoCRM.
        #
        # If record with specified id does not exists, it raises exception.
        #
        # @param [String] id
        # @raise RecordNotFound
        def find(id)
          load_single_record(id)
        end

        # Loads single record from amoCRM.
        #
        # If record with specified id does not exists, it raises exception.
        #
        # @param [String] id
        # @raise RecordNotFound
        def find!(id)
          record = find(id)
          fail(RecordNotFound) unless record

          record
        end

        # TODO: Write documentation.
        def all
          response = client.safe_request(:get, amo_name)
          load_many_records(response)
        end

        # TODO: Write documentation.
        def first(number = 1)
          number > 1 ? all.first(number) : all.first
        end

        # TODO: Write documentation.
        def last(number = 1)
          number > 1 ? all.last(number) : all.last
        end

        # TODO: Write documentation.
        # Especially about 'query' request.
        def where(attributes)
          response = client.safe_request(:get, amo_name, attributes)
          load_many_records(response)
        end

        private

        # We can have response with 200 or 204 here.
        # 204 response has no body, so we don't want to parse it.
        def load_many_records(response)
          return [] if response.status == 204

          return [] if response.body.presence.nil?

          data = response.body.dig('_embedded', 'items') || []
          data.map { |attributes| new.merge_attributes(attributes) }
        end

        def load_single_record(id)
          response = client.safe_request(:get, amo_name, id: id)

          return if response.body.presence.nil?

          attributes = response.body.dig('_embedded', 'items').first
          return if attributes.nil?

          new.merge_attributes(attributes)
        end
      end
    end
  end
end
