class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

private

  def set_domain
    @domain = Domain.find_by(name: params[:domain_name])
  end

  def set_board
    board = @domain.boards.find_by(jira_id: params[:board_id])

    unless params[:from_state].blank?
      from_state = params[:from_state]
    end
    unless params[:to_state].blank?
      to_state = params[:to_state]
    end

    unless params[:from_date].blank?
      from_date = Time.parse(params[:from_date])
      to_date = Time.parse(params[:to_date]) unless params[:to_date].blank?
      date_range = DateRange.new(from_date, to_date)
    end

    @board = BoardDecorator.new(board, from_state, to_state, date_range, params[:query])
  end
end
