class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

private

  def set_domain
    @domain = Domain.find_by(name: params[:domain_name])
  end

  def set_board
    board = @domain.boards.find(params[:board_id])

    unless params[:from_state].nil?
      from_state = params[:from_state] unless params[:from_state].empty?
    end
    unless params[:to_state].nil?
      to_state = params[:to_state] unless params[:to_state].empty?
    end

    @board = BoardDecorator.new(board, from_state, to_state)
  end
end
