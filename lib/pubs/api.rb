require 'goliath/websocket'
require 'pubs/channels'

module Pubs

  module Api
  end

  class API < Goliath::WebSocket

    include Goliath::Constants
    ACTIVE_RECORD = "ActiveRecord"
    HTTP_SEC_WEBSOCKET_KEY = 'HTTP_SEC_WEBSOCKET_KEY'

    class << self

      include Goliath::Constants

      def routes
        @routes ||= {}
      end

      def get(route, &block)
        register_route(:get, route, &block)
        register_route(:head, route, &block)
      end

      def post(route, &block)
        register_route(:post, route, &block)
      end

      def put(route, &block)
        register_route(:put, route, &block)
      end

      def patch(route, &block)
        register_route(:patch, route, &block)
      end

      def delete(route, &block)
        register_route(:delete, route, &block)
      end

      def head(route, &block)
        register_route(:head, route, &block)
      end

      def options(route, &block)
        register_route(:options, route, &block)
      end

      def register_route(method, route, &block)
        self.routes[self.signature(method, route)] = block
      end

      def signature(method, route)
        v = :"@@#{method}#{route.parameterize.underscore}"
        begin
          class_variable_get(v)
        rescue
          class_variable_set(v,"#{method.to_s.upcase}#{route}")
        end
      end

      def inherited klass
        klass.use Goliath::Rack::Heartbeat
        klass.use Goliath::Rack::Params
        # klass.use Goliath::Rack::Render, 'json'
        super
      end

    end

    def on_open(env)
      env[:subscription] = channel.subscribe { |m|
        env.stream_send(m)
      }
    end

    def on_message(env,msg)
      @env = env
      request = JSON.parse(msg)

      env['params'] = env[RACK_INPUT] = request['body'] || {}
      env[:private_channel] = true if request['private']

      if block = self.class.routes[signature(request['method'], env[REQUEST_PATH])]
       publish!(process(block))
      else
        publish!([404,{},Goliath::HTTP_STATUS_CODES[404]])
      end
    end

    def on_close(env)
      channel.unsubscribe(env[:subscription]) if env[:subscription]
    end

    def on_body(env, data)
      @env = env
      if env.respond_to? :handler
        super env, data
      else
        (env[RACK_INPUT] ||= '') << data
      end
    end

    def response(env)

      # WebSocket messaging
      if env[REQUEST_PATH].start_with?("/ws")

        env[REQUEST_PATH] = env[REQUEST_PATH].gsub("/ws","")

        super(env)

      # RESTful Routing
      else
        error!(404) unless block = self.class.routes[signature(env[REQUEST_METHOD], env[REQUEST_PATH])]
        process(block)
      end

    end

    private

    def publish! response
      channel << response.to_json
    end

    def channel
      Pubs.channels[env[:private_channel] ? private_channel : public_channel]
    end

    def private_channel
      "#{public_channel}@#{env[HTTP_SEC_WEBSOCKET_KEY]}"
    end

    def public_channel
      signature(env[REQUEST_METHOD], env[REQUEST_PATH])
    end

    def process(block)

      begin
        status = 200
        body = instance_exec(&block) # always returns JSON string
      rescue Exception => e
        if e.class.name.start_with? ACTIVE_RECORD
          status = 406
          body = e.try(:record).try(:errors).to_json || e.message.to_json
        else
          raise e
          status = 500
          body = e.message.to_json
        end
      end

      [status, header, body]

    end

    def header
      {"Content-Type" => "application/json"}
    end

    def signature(method,path)
      self.class.signature(method,path)
    end

    def error! code
      raise Goliath::Validation::Error.new(code, Goliath::HTTP_STATUS_CODES[code])
    end

  end


end