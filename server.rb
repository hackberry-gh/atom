require './config/env'
require 'config/application'
require 'goliath'
require "app/api/#{ARGV[0]}"