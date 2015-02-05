require 'active_model'

module Amorail
  class AmoEntity

    include ActiveModel::Model
    include ActiveModel::AttributeMethods
    include ActiveModel::Validations

    class << self
      attr_reader :amo_name
      def set_amo_name(name)
        @amo_name = name
      end
    end

    attr_accessor :date_create, :last_modified, 
                  :request_id, :responsible_user_id

    attr_reader :id

    def initialize(attributes={})
      super
      @client = Amorail.client
      @properties = Amorail.properties
    end

    def self.attr_accessor(*vars)
      @attributes ||= []
      @attributes.concat vars
      super(*vars)
    end

    def create_params
      {}
    end

    def self.attributes
      @attributes
    end

    def attributes
      attrs = {}
      self.attributes_list.each { |a| attrs[a] = self.send(a) } 
      attrs
    end

    def attributes_list
      self.class.attributes
    end

    def client
      @client
    end

    def properties
      @properties
    end

    def save
      if valid?
        safe_create
      else
        false
      end
    end

    def save!
      if valid?
        create
      else
        false
      end
    end

    def create
      response = client.post(
        url, 
        create_url, 
        normalize_params(create_params)
      )
      true if response.status == 200 or response.status == 204
    end

    # call safe method <safe_request>. safe_request call authorize
    # if current session undefined or expires.
    def safe_create
      response = client.safe_request(
        :post, 
        create_url, 
        normalize_params(create_params)
      )
      if response.status == 200 or response.status == 204
        reload_model(response.body["response"])
        true
      else
        false
      end
    end

    # override this method for Amo<Any> class

    def reload_model(response)
    end

    # this method removes nil values and empty arrays from params hash (deep)
    def normalize_params(data)
      return data unless data.is_a?(Hash)

      compacted = {}
      data.each do |key,val|
        case val
        when Numeric, String
          compacted[key]=val
        when Array
          val.compact!
          # handle custom keys
          val=normalize_custom_fields(val) if key == :custom_fields
          unless val.empty?
            compacted[key] = val.map{|el| normalize_params(el) } 
          end
        else
          _data = normalize_params(val)
          compacted[key] = _data unless _data.nil?
        end
      end
      compacted
    end

    def normalize_custom_fields(val)
      val.reject do |field|
        field[:values].all?{ |item| !item[:value] }
      end
    end

    protected
    
    def to_timestamp(val)
      return if val.nil?

      case val
      when String
        (_date=Date.parse(val)) && _date.to_i
      when Date
        val.to_i
      when Numeric
        val.to_i
      end
    end

    private
  
    def create_url
      File.join("#{Amorail.config.api_path}", self.class.amo_name, "set")
    end
  end
end