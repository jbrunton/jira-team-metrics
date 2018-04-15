class JiraTeamMetrics::DeliveryReportBuilder < ReportBuilder
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
    @increment_report ||= IncrementScopeReport.new(@increment).build
  end

  def cfd_data(cfd_type)
    increment_report.cfd_data(cfd_type)
  end

  def team_dashboard_data
    {
      totals: team_dashboard_row_data(increment_report),
      teams: increment_report.teams.map do |team|
        team_report = @increment_report.team_report_for(team)
        [team, team_dashboard_row_data(team_report).merge({
          status_color: @increment.target_date ? team_report.status_color : nil,
          rolling_completion_date: team_report.rolling_forecast_completion_date(7),
          trained_completion_date: team_report.trained_completion_date
        })]
      end.to_h
    }
  end

  def team_dashboard_row_data(report)
    {
      scope: report.scope.count,
      remaining_scope: report.remaining_scope.count,
      predicted_scope: report.predicted_scope.count,
      completed_scope: report.completed_scope.count,
      progress_percent: 100.0 * report.completed_scope.count / report.scope.count,
      rolling_completion_rate: report.rolling_completion_rate(7),
      trained_completion_rate: report.trained_completion_rate
    }
  end
end