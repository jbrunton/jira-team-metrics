require 'sinatra'
require 'sinatra/content_for'
require 'yaml/store'
require 'byebug'

require 'require_all'
['helpers', 'models', 'stores', 'app'].each { |dir| require_all dir }

helpers do
  include ApplicationHelper
end

