require 'em-synchrony/em-http'
require 'em-websocket-client'
require 'goliath/test_helper'
require 'goliath/test_helper_streaming'
require 'goliath/test_helper_ws'
require 'pubs/api'

# require "lib/jobs/base"
# require "lib/jobs/send_email"
# require "lib/jobs/send_fb_message"
# require 'lib/mailer'

Goliath.env = :test
ENV['APP_NAME'] = "atom"
ENV['ALLOWED_ORIGINS'] = "http://localhost:3000"
ENV['TIME_ZONE'] = "London"


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