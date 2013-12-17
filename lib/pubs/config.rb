require 'yaml'
require 'erb'
require 'pathname'
require 'active_record'
require "active_support/concern"
require "active_support/string_inquirer"
require "active_support/inflector"
require "pubs/core_ext/kernel"

module Pubs
  module Config

    RUNNER = "server.rb"

    extend ActiveSupport::Concern

    module ClassMethods
      
      def app_name
        @@app_name ||= ENV['APP_NAME']
      end
      
      def establish_connection
        if env.production?
          db = ENV['DATABASE_URL']
          ActiveRecord::Base.establish_connection(
          adapter:      'postgresql',
          host:         db.host,
          username:     db.user,
          port:         db.port,
          password:     db.password,
          database:     db.path[1..-1],
          encoding:     'utf8',
          pool:         ENV['DB_POOL'] || 5,
          connections:  ENV['DB_CONNECTIONS'] || 20,
          reaping_frequency: ENV['DB_REAP_FREQ'] || 10
          )
        else # local environment
          ActiveRecord::Base.establish_connection(config(:database))
        end
      end

      def config name
        name = "#{name}.yml" unless /\.yml/ =~ name
        var_name = "@#{name.parameterize.underscore}"
        unless config = instance_variable_get(var_name)
          config = instance_variable_set(var_name,
          YAML.load(ERB.new(File.read("#{root}/config/#{name}")).result)[env]
          )
        end
        config
      end

      def env env = nil
        @@env ||= ActiveSupport::StringInquirer.new(ENV['RACK_ENV'] ||= 'development')
      end

      def env=(environment)
        @@env = ENV['RACK_ENV'] = ActiveSupport::StringInquirer.new(environment)
      end

      def root
        @@root ||= find_root_with_flag(RUNNER, Dir.pwd).to_s
      end

      def root= root
        @@root = root
      end

      def path
        @@path ||= File.expand_path('../../..', __FILE__)
      end

      def load_env_vars file = "#{root}/.env"
        unless File.exists?(file)
          puts "File not found for load_env_vars #{file}"
          return false
        end
        Hash[File.read(file).gsub("\n\n","\n").split("\n").compact.map{ |v|
          v.split("=")
        }].each { |k,v| ENV[k] = v }
      end

      def inside_app?
        File.exist?("#{root}/#{RUNNER}")
      end

      private

      # i steal this from rails
      def find_root_with_flag(flag, default=nil)
        root_path = self.class.called_from[0]

        while root_path && File.directory?(root_path) && !File.exist?("#{root_path}/#{flag}")
          parent = File.dirname(root_path)
          root_path = parent != root_path && parent
        end

        root = File.exist?("#{root_path}/#{flag}") ? root_path : default
        raise "Could not find root path for #{self}" unless root

        RbConfig::CONFIG['host_os'] =~ /mswin|mingw/ ?
        Pathname.new(root).expand_path : Pathname.new(root).realpath
      end

    end

  end
end