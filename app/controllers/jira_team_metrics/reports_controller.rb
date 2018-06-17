class JiraTeamMetrics::ReportsController < JiraTeamMetrics::ApplicationController
  before_action :set_domain
  before_action :set_board

  def timesheets
    @timesheet_options = JiraTeamMetrics::TimesheetOptions.new(@chart_params, @board.config.timesheets_config).build
  end

  def throughput
  end

  def deliveries
    @increments = @board.increments
  end

  def delivery
    @board = JiraTeamMetrics::Board.find_by(jira_id: @board.jira_id)
    @increment = @board.issues.find_by(key: params[:issue_key])
    @remaining_teams = team_dashboard_data[:teams].select do |_, team_data|
      team_data[:remaining_scope] > 0
    end
  end

  def scatterplot
  end

  def aging_wip
  end

  def delivery_scope
    @team = params[:team]
    @increment = @board.issues.find_by(key: params[:issue_key])

    @report = JiraTeamMetrics::TeamScopeReport.for(@increment, @team)
    @issues_by_epic = @report.scope
      .group_by{ |issue| issue.epic }
      .sort_by{ |epic, _| epic.nil? ? 1 : 0 }
      .to_h
  end

  def delivery_throughput
    @team = params[:team]
    @increment = @board.issues.find_by(key: params[:issue_key])
  end

  def increment_report
    @increment_report ||= JiraTeamMetrics::IncrementScopeReport.new(@increment).build
  end

  helper_method :cfd_data
  helper_method :team_dashboard_data
  helper_method :increment_report

  def cfd_data(cfd_type)
    JiraTeamMetrics::ReportFragment.fetch_contents(@increment.board, report_key, "cfd:#{cfd_type}")
  end

  def team_dashboard_data
    JiraTeamMetrics::ReportFragment.fetch_contents(@increment.board, report_key, "team_dashboard")
  end

  def report_key
    "delivery/#{@increment.key}"
  end
end