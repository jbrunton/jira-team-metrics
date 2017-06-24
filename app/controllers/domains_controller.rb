class DomainsController < ApplicationController
  before '/:domain*' do
    domain_name = params[:domain]
    @domain = DomainsStore.instance.find(domain_name)
  end

  before '/:domain/boards/:board_id*' do
    board = Store::Boards.instance(@domain['name']).get_board(params[:board_id].to_i)

    unless params[:from_state].nil?
      from_state = params[:from_state] unless params[:from_state].empty?
    end
    unless params[:to_state].nil?
      to_state = params[:to_state] unless params[:to_state].empty?
    end

    @board = BoardDecorator.new(board, from_state, to_state)
  end

  get '/' do
    @domains = DomainsStore.instance.all
    erb 'domains/index'.to_sym
  end

  get '/:domain' do
    @boards = Store::Boards.instance(@domain['name']).all.select do |board|
      !board.last_updated.nil?
    end
    erb 'domains/show'.to_sym
  end
end
