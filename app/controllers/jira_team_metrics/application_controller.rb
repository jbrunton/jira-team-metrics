class JiraTeamMetrics::ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

private

  def set_domain
    @domain = JiraTeamMetrics::Domain.get_instance
  end

  def set_board
    @board = @domain.boards.find_by(jira_id: params[:board_id])
    @report_params = JiraTeamMetrics::ReportParams.from_params(params)
    @timesheet_options = JiraTeamMetrics::TimesheetOptions.new(@report_params, @board.config.timesheets_config).build
  end
end
