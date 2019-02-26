require 'active_model'
require 'active_support'
require 'faraday'
require 'faraday_middleware'
require 'json'

require_relative 'amorail/client'
require_relative 'amorail/config'
require_relative 'amorail/exceptions'
require_relative 'amorail/version'
require_relative 'amorail/property'

require_relative 'amorail/base_entity/attributes'
require_relative 'amorail/base_entity/persistence'
require_relative 'amorail/base_entity/finders'
require_relative 'amorail/base_entity/class_methods'
require_relative 'amorail/base_entity/relations'
require_relative 'amorail/base_entity'

require_relative 'amorail/entities/concerns/taggable'
require_relative 'amorail/entities/company'
require_relative 'amorail/entities/contact'
require_relative 'amorail/entities/custom_field'
require_relative 'amorail/entities/lead'
require_relative 'amorail/entities/pipeline_status'
require_relative 'amorail/entities/pipeline'
require_relative 'amorail/entities/task'
require_relative 'amorail/entities/note'

module Amorail
  def self.config
    @config ||= Config.new
  end

  def self.properties
    client.properties
  end

  def self.configure
    yield(config) if block_given?
  end

  def self.client
    ClientRegistry.client || (@client ||= Client.new)
  end

  def self.reset
    @config = nil
    @client = nil
  end

  def self.with_client(client)
    client = Client.new(client) unless client.is_a?(Client)
    ClientRegistry.client = client
    yield
  ensure
    ClientRegistry.client = nil
  end

  class ClientRegistry # :nodoc:
    extend ActiveSupport::PerThreadRegistry

    attr_accessor :client
  end
end
