require 'goliath/rack'
require 'pubs/cache'

module Pubs
  module Api
    class AccessControl

      include Pubs::Cache

      X_API_KEY = 'X-Api-Key'

      include Goliath::Rack::AsyncMiddleware

      DEFAULT_CORS_HEADERS = {
        'Access-Control-Allow-Origin'   => '*',
        'Access-Control-Expose-Headers' => X_API_KEY,
        'Access-Control-Max-Age'        => '0',
        'Access-Control-Allow-Methods'  => 'GET, HEAD, OPTIONS, POST, PUT, PATCH, DELETE',
        'Access-Control-Allow-Headers'  => 'Content-Type,X-Api-Key'
        # 'Access-Control-Allow-Credentials' => 'true'
      }.freeze

      def call(env, *args)
        # XHR? what? piss off dude it's CORS
        raise Goliath::Validation::UnauthorizedError if env["HTTP_X_REQUESTED_WITH"] == "XMLHttpRequest"
        
        # Authenticate By Api Key if request not an CORS ajax
        raise Goliath::Validation::UnauthorizedError unless authorize_key!(env)

        # CROSS DOMAIN ORIGIN CHECK
        if env['HTTP_ORIGIN'].present? && env['config']['allowed_origins'].include?( env['HTTP_ORIGIN']  ).nil?
          raise Goliath::Validation::UnauthorizedError
        end

        # Check Access-Control Headers
        if env["REQUEST_METHOD"] == "OPTIONS"
          return [200, access_control_headers(env), []]
        end

        super(env)
      end

      def post_process(env, status, headers, body)

        unless env['HTTP_ORIGIN'].nil?
          headers['ACCESS_CONTROL_ALLOW_ORIGIN'] = '*'
          headers['Access-Control-Allow-Headers'] = X_API_KEY
        end

        [status, headers, body]
      end

      private

      def access_control_headers(env)
        cors_headers = DEFAULT_CORS_HEADERS.dup
        client_headers_to_approve = env['HTTP_ACCESS_CONTROL_REQUEST_HEADERS'].to_s.gsub(/[^\w\-\,]+/,'')
        cors_headers['ACCESS_CONTROL_ALLOW_HEADERS'] += ",#{client_headers_to_approve}" if not client_headers_to_approve.empty?
        cors_headers
      end

      # Ensure Clients can have API KEY FROM Somewhere
      def authorize_key!(env)

        # SKIP CORS Level Auth for websockets
        return true if env['HTTP_SEC_WEBSOCKET_KEY'] && ENV['RACK_ENV'] == "test"

        env[X_API_KEY] ||= env["goliath.request-headers"][X_API_KEY]
        raise Goliath::Validation::UnauthorizedError if env[X_API_KEY].nil? || Pubs::Api.auth_key!(env[X_API_KEY]).nil?
        true
      end

    end

  end
end