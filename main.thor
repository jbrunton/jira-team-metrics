require './config/environment'

require 'require_all'

['helpers', 'models', 'stores', 'tasks'].each { |dir| require_all dir }
