

module ApiAuth
  module RequestDrivers
    class << self

      def drivers
        @drivers ||= {}
      end

    end
  end
end

require 'api_auth/request_drivers/net_http'
require 'api_auth/request_drivers/curb'
require 'api_auth/request_drivers/rest_client'
require 'api_auth/request_drivers/action_controller'
require 'api_auth/request_drivers/action_dispatch'
require 'api_auth/request_drivers/rack'
require 'api_auth/request_drivers/httpi'
