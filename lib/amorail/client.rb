module Amorail
  # Amorail http client
  class Client
    SUCCESS_STATUS_CODES = [200, 204].freeze

    attr_reader :usermail, :api_key, :api_endpoint

    # Initializes new Amorail client with default params from config.
    def initialize(api_endpoint: Amorail.config.api_endpoint,
                   api_key: Amorail.config.api_key,
                   usermail: Amorail.config.usermail)

      @api_endpoint = api_endpoint
      @api_key = api_key
      @usermail = usermail

      @connection = Faraday.new(url: api_endpoint) do |faraday|
        faraday.response :json, content_type: /\bjson$/
        faraday.use :instrumentation
        faraday.adapter Faraday.default_adapter
      end
    end

    def properties
      @properties ||= Property.new(self)
    end

    def authorize
      self.cookies = nil
      response = post(
        Amorail.config.auth_url,
        'USER_LOGIN' => usermail,
        'USER_HASH' => api_key
      )
      cookie_handler(response)
      response
    end

    def safe_request(method, name, params = {})
      retries ||= 0
      public_send(method, params[:url] || remote_url_for(name), params)
    rescue ::Amorail::AmoUnauthorizedError
      authorize
      retry if (retries += 1) < 3
      public_send(method, params[:url] || remote_url_for(name), params)
    end

    def get(url, params = {})
      response = connection.get(url, params) do |request|
        request.headers['Cookie'] = cookies if cookies.present?
      end
      handle_response(response)
    end

    def post(url, params = {})
      response = connection.post(url) do |request|
        request.headers['Cookie'] = cookies if cookies.present?
        request.headers['Content-Type'] = 'application/json'
        request.body = params.to_json
      end
      handle_response(response)
    end

    private

    attr_accessor :cookies

    def remote_url_for(name)
      File.join(Amorail.config.api_path, name)
    end

    def connection
      @connection || self.class.new
    end

    def cookie_handler(response)
      self.cookies = response.headers['set-cookie'].split('; ')[0]
    end

    def handle_response(response)
      return response if SUCCESS_STATUS_CODES.include?(response.status)

      case response.status
      when 301
        raise_exception(AmoMovedPermanentlyError, response)
      when 400
        raise_exception(AmoBadRequestError, response)
      when 401
        raise_exception(AmoUnauthorizedError, response)
      when 403
        raise_exception(AmoForbiddenError, response)
      when 404
        raise_exception(AmoNotFoundError, response)
      when 500
        raise_exception(AmoInternalError, response)
      when 502
        raise_exception(AmoBadGatewayError, response)
      when 503
        raise_exception(AmoServiceUnavailableError, response)
      else
        raise_exception(AmoUnknownError, response)
      end
    end

    def raise_exception(klass, response)
      raise(klass, body: response.body, status: response.status)
    end
  end
end
