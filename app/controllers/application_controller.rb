class ApplicationController < Sinatra::Base
  helpers Sinatra::ContentFor
  helpers ApplicationHelper

  # set folder for templates to ../views, but make the path absolute
  set :views, File.expand_path('../../views', __FILE__)

  before('/:domain*') { set_domain(params) }
  before('/:domain/boards/:board_id*') { set_board(params) }

private
  def set_domain(params)
    domain_name = params[:domain]
    @domain = DomainsStore.instance.find(domain_name)
  end

  def set_board(params)
    board = Store::Boards.instance(@domain['name']).get_board(params[:board_id].to_i)

    unless params[:from_state].nil?
      from_state = params[:from_state] unless params[:from_state].empty?
    end
    unless params[:to_state].nil?
      to_state = params[:to_state] unless params[:to_state].empty?
    end

    @board = BoardDecorator.new(board, from_state, to_state)
  end
end