class JiraTeamMetrics::ProjectReportBuilder < JiraTeamMetrics::ReportBuilder
  def initialize(project, sync_history_id)
    super(project.board,
      sync_history_id,
      "project/#{project.key}",
      %w(team_dashboard cfd:raw cfd:trained))
    @project = project
  end

  def fragment_data_for(fragment_key)
    case
      when fragment_key == 'team_dashboard'
        team_dashboard_data
      when fragment_key == 'cfd:raw'
        cfd_data(:raw)
      when fragment_key == 'cfd:trained'
        cfd_data(:trained)
      else
        super(fragment_key)
    end
  end

private
  def project_report
    @project_report ||= JiraTeamMetrics::ProjectScopeReport.new(@project).build
  end

  def rolling_window_days
    @project.board.config.rolling_window.days
  end

  def cfd_data(cfd_type)
    project_report.cfd_data(cfd_type)
  end

  def team_dashboard_data
    {
      rolling_window_days: rolling_window_days,
      totals: aggregate_data_for(project_report),
      teams: project_report.teams.map do |team|
        team_report = @project_report.team_report_for(team)
        [team, aggregate_data_for(team_report).merge(team_data_for(team_report))]
      end.to_h
    }
  end

  def team_data_for(team_report)
    rounded_epic_scope = team_report.predicted_epic_scope.round
    {
      status_color: @project.target_date ? team_report.status_color : nil,
      status_reason: @project.target_date ? team_report.status_reason : nil,
      rolling_completion_date: team_report.rolling_forecast_completion_date(rolling_window_days),
      rolling_lead_time: team_report.rolling_forecast_lead_time(rolling_window_days),
      predicted_completion_date: team_report.predicted_completion_date,
      predicted_lead_time: team_report.predicted_lead_time,
      predicted_scope_tooltip: "#{team_report.unscoped_epics.count} unscoped epics, predicting #{rounded_epic_scope || 0} #{'issue'.pluralize(rounded_epic_scope)} / epic."
    }
  end

  def aggregate_data_for(report)
    {
      scope: report.scope.count,
      epics: report.epics.count,
      unscoped_epics: report.unscoped_epics.count,
      remaining_scope: report.remaining_scope.count,
      predicted_scope: report.predicted_scope.count,
      completed_scope: report.completed_scope.count,
      progress_percent: 100.0 * report.completed_scope.count / report.scope.count,
      rolling_throughput: report.rolling_throughput(rolling_window_days),
      predicted_throughput: report.predicted_throughput,
      predicted_epic_scope: report.predicted_epic_scope
    }
  end
end