require 'sinatra'
require 'sinatra/content_for'
require 'yaml/store'

require 'require_all'
['models', 'stores'].each { |dir| require_all dir }

helpers do
  def home_path
    '/'
  end

  def domain_path(domain)
    "/#{domain['name']}"
  end

  def board_path(domain, board)
    "#{domain_path(domain)}/boards/#{board.id}"
  end

  def board_issues_path(domain, board)
    "#{board_path(domain, board)}/issues"
  end
end

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

get '/:domain/boards/:id' do
  domain_name = params['domain']
  @domain = DomainsStore.instance.find(domain_name)
  board = Store::Boards.instance(domain_name).get_board(params[:id].to_i)
  @board = BoardDecorator.new(board, nil, nil)
  erb 'boards/show'.to_sym
end

get '/:domain/boards/:id/issues' do
  domain_name = params['domain']
  @domain = DomainsStore.instance.find(domain_name)
  board = Store::Boards.instance(domain_name).get_board(params[:id].to_i)
  @board = BoardDecorator.new(board, nil, nil)
  erb 'boards/issues'.to_sym
end
