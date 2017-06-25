class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

private

  def set_domain
    @domain = Domain.find_by(name: params[:domain_name])
  end

  def set_board
    board = Store::Boards.instance(@domain.name).get_board(params[:board_id].to_i)

    unless params[:from_state].nil?
      from_state = params[:from_state] unless params[:from_state].empty?
    end
    unless params[:to_state].nil?
      to_state = params[:to_state] unless params[:to_state].empty?
    end

    @board = BoardDecorator.new(board, from_state, to_state)
  end
end
