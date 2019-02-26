require 'anyway'

module Amorail
  class Config < Anyway::Config
    attr_config :usermail,
                :api_key,
                :api_endpoint,
                api_path: '/api/v2/',
                auth_url: '/private/api/auth.php?type=json'
  end
end
