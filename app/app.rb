require 'sinatra'
require 'sinatra/content_for'
require 'yaml/store'

require 'require_all'
['models', 'stores'].each { |dir| require_all dir }

get '/' do
  @domains = DomainsStore.instance.all
  erb 'domains/index'.to_sym
end

get '/:domain' do
  domain_name = params['domain']
  @domain = DomainsStore.instance.find(domain_name)
  @boards = Store::Boards.instance(domain_name).all.select do |board|
    !board.last_updated.nil?
  end
  erb 'domains/show'.to_sym
end
