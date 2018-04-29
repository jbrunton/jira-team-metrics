class JiraTeamMetrics::DeliveryReportBuilder < JiraTeamMetrics::ReportBuilder
  def initialize(increment)
    super(increment.board,
      "delivery/#{increment.key}",
      %w(team_dashboard cfd:raw cfd:trained))
    @increment = increment
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
  def increment_report
    @increment_report ||= JiraTeamMetrics::IncrementScopeReport.new(@increment).build
  end

  def rolling_window_days
    @increment.board.config.rolling_window_days
  end

  def cfd_data(cfd_type)
    increment_report.cfd_data(cfd_type)
  end

  def team_dashboard_data
    {
      rolling_window_days: rolling_window_days,
      totals: aggregate_data_for(increment_report),
      teams: increment_report.teams.map do |team|
        team_report = @increment_report.team_report_for(team)
        [team, aggregate_data_for(team_report).merge(target_data_for(team_report))]
      end.to_h
    }
  end

  def target_data_for(team_report)
    {
      status_color: @increment.target_date ? team_report.status_color : nil,
      status_reason: @increment.target_date ? team_report.status_reason : nil,
      rolling_completion_date: team_report.rolling_forecast_completion_date(rolling_window_days),
      trained_completion_date: team_report.trained_completion_date
    }
  end

  def aggregate_data_for(report)
    {
      scope: report.scope.count,
      remaining_scope: report.remaining_scope.count,
      predicted_scope: report.predicted_scope.count,
      completed_scope: report.completed_scope.count,
      progress_percent: 100.0 * report.completed_scope.count / report.scope.count,
      rolling_completion_rate: report.rolling_completion_rate(rolling_window_days),
      trained_completion_rate: report.trained_completion_rate
    }
  end
end