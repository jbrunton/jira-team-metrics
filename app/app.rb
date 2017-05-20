require 'sinatra'
require 'yaml/store'

require 'require_all'
['models', 'stores'].each { |dir| require_all dir }

get '/' do
  @domains = DomainsStore.instance.all
  erb :index
end

get '/:domain' do
  domain_name = params['domain']
  @domain = DomainsStore.instance.find(domain_name)
  @boards = Store::Boards.instance(domain_name).all.select do |board|
    !board.last_updated.nil?
  end
  erb 'boards/index'.to_sym
end
