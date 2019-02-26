require_relative 'property/property_item'
require_relative 'property/company'
require_relative 'property/contact'
require_relative 'property/lead'
require_relative 'property/task'

module Amorail
  class Property # :nodoc: all
    API_ENDPOINT_URL = '/private/api/v2/json/accounts/current'.freeze

    attr_reader :data
    attr_reader :contacts
    attr_reader :company
    attr_reader :leads
    attr_reader :tasks

    def initialize(client)
      @client = client
      reload
    end

    def reload
      fetch_account_data
      parse_entities
    end

    def inspect
      @data
    end

    private

    def fetch_account_data
      response = @client.safe_request(:get, nil, url: API_ENDPOINT_URL)
      @data = response.body['response']['account']
    end

    def parse_entities
      @contacts = Contact.parse(data)
      @company = Company.parse(data)
      @leads = Lead.parse(data)
      @tasks = Task.parse(data)
    end
  end
end
