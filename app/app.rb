require 'sinatra'
require 'yaml/store'

require 'require_all'
['models', 'stores'].each { |dir| require_all dir }

get '/' do
  @domains = DomainsStore.instance.all
  erb :index
end
