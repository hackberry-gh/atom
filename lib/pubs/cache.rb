require 'dalli'
require "singleton"
require 'active_support/concern'

module Pubs
  module Cache

    extend ActiveSupport::Concern

    module ClassMethods

      def cache
        Cache::Client.instance
      end
      
      # shorthand namespacing for indy apps
      def n key
        "#{Pubs.app_name}:#{key}"
      end

    end

    # def cache
#       Cache::Client.instance
#     end
    include ClassMethods

    class Client

      include Singleton

      def self.instance
        return @instance if @instance
        config = YAML::load(ERB.new(File.read("config/cache.yml")).result)[Pubs.env]
        @instance = Dalli::Client.new config.delete("servers").split(","), config
      end

    end

  end
end