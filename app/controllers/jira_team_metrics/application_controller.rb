class JiraTeamMetrics::ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

private

  def set_domain
    @domain = JiraTeamMetrics::Domain.get_instance
  end

  def set_board
    board = @domain.boards.find_by(jira_id: params[:board_id])

    unless params[:from_state].blank?
      from_state = params[:from_state]
    end
    unless params[:to_state].blank?
      to_state = params[:to_state]
    end

    if params[:from_date].blank? || params[:to_date].blank?
      @default_from_date = board.synced_from || Time.now - 90.days
      @default_to_date = Time.now
    else
      from_date = Time.parse(params[:from_date])
      to_date = Time.parse(params[:to_date])
      @date_range = JiraTeamMetrics::DateRange.new(from_date, to_date)

      @default_from_date = from_date
      @default_to_date = to_date
    end

    @board = JiraTeamMetrics::BoardDecorator.new(board, from_state, to_state, @date_range, params[:query])
  end

  def render_unauthorized
    render json: {}, status: 401
  end
end
