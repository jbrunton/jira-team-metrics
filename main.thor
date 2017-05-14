require 'require_all'

['models', 'stores', 'tasks'].each { |dir| require_all dir }
