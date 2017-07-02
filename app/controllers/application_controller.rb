class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

private

  def set_domain
    @domain = Domain.find_by(name: params[:domain_name])
  end

  def set_board
    board = @domain.boards.find_by(jira_id: params[:board_id])

    unless params[:from_state].nil?
      from_state = params[:from_state] unless params[:from_state].empty?
    end
    unless params[:to_state].nil?
      to_state = params[:to_state] unless params[:to_state].empty?
    end

    filters = (params[:filters] || [])
    exclude_filters = board.filters.select{ |filter| !filters.include?(filter.id.to_s) }
    exclude_filters.each { |f| puts "Excluding " + f.name }
    @board = BoardDecorator.new(board, from_state, to_state, exclude_filters)
  end
end
