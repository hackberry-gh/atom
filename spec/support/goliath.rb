require 'em-synchrony/em-http'
require 'em-websocket-client'
require 'goliath/test_helper'
require 'goliath/test_helper_streaming'
require 'goliath/test_helper_ws'
# require 'pubs/api'

# require "lib/jobs/base"
# require "lib/jobs/send_email"
# require "lib/jobs/send_fb_message"
# require 'lib/mailer'

Goliath.env = :test
# ENV['APP_NAME'] = "pubs-backend"
# ENV['ALLOWED_ORIGINS'] = "http://localhost:5000"
# ENV['ALLOWED_ORIGINS'] = "London"
# Pubs.config(:roles).keys.each_with_index do |role,index|
#   Pubs::Api.set_key!(role, {id: index, email: "#{role}@pubs.io", role: role})
# end

module Goliath
  module TestHelper
    class StreamingHelper
      def initialize(params)
        @queue = EM::Queue.new

        fiber = Fiber.current
        @connection = EventMachine::HttpRequest.new(params.delete(:path)).get params
        @connection.errback do |e|
          puts "Error encountered during connection: #{e}"
          EM::stop_event_loop
        end

        @connection.callback { EM::stop_event_loop }

        @connection.stream { |m| @queue.push(m) }

        Fiber.yield
      end
    end
    def streaming_client_connect(params, &blk)
      params[:path] = "http://localhost:#{@test_server_port}#{params.delete(:path)}"
      client = StreamingHelper.new(params)
      blk.call(client) if blk
      stop
    end
  end
end

class MiniTest::Spec
  include Goliath::TestHelper
end