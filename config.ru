# This file is used by Rack-based servers to start the application.

require 'yaml/store'
require 'require_all'
['helpers', 'models', 'stores'].each { |dir| require_all dir }

require_relative 'config/environment'

run Rails.application
