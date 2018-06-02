class JiraTeamMetrics::ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

private

  def set_domain
    @domain = JiraTeamMetrics::Domain.get_instance
  end

  def set_board
    @board = @domain.boards.find_by(jira_id: params[:board_id])
    @chart_params = JiraTeamMetrics::ChartParams.from_params(@board, params)
  end

  def render_unauthorized
    render json: {}, status: 401
  end

  def render_syncing
    render json: { responseText: 'Sync in progress. Try again later.' }, status: 400
  end
end
