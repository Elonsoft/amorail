require_relative 'property/property_item'
require_relative 'property/company'
require_relative 'property/contact'
require_relative 'property/lead'
require_relative 'property/task'

module Amorail
  class Property # :nodoc: all
    API_ENDPOINT_URL = '/api/v2/account?with=custom_fields,users,pipelines,note_types,task_types'.freeze

    attr_reader :data
    attr_reader :contacts
    attr_reader :companies
    attr_reader :leads
    attr_reader :tasks

    def initialize(client)
      @client = client
      reload
    end

    def reload
      fetch_account_data
      parse_custom_fields_info
    end

    def inspect
      @data
    end

    private

    def fetch_account_data
      response = @client.safe_request(:get, nil, url: API_ENDPOINT_URL)
      @data = response.body
    end

    def parse_custom_fields_info
      custom_fields = data.dig('_embedded', 'custom_fields') || {}

      @contacts = Contact.parse(custom_fields)
      @companies = Company.parse(custom_fields)
      @leads = Lead.parse(custom_fields)
      @tasks = Task.parse(custom_fields)
    end
  end
end
