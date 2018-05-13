class JiraTeamMetrics::MetricAdjustments
  def initialize(team_adjustments)
    @team_adjustments = team_adjustments
  end

  def adjusted_epic_scope(short_team_name, trained_epic_scope)
    team_adjustment = JiraTeamMetrics::TeamAdjustment.new(@team_adjustments[short_team_name] || {})
    team_adjustment.adjusted_epic_scope(trained_epic_scope)
  end

  def adjusted_throughput(short_team_name, trained_throughput)
    team_adjustment = JiraTeamMetrics::TeamAdjustment.new(@team_adjustments[short_team_name] || {})
    team_adjustment.adjusted_throughput(trained_throughput)
  end
end
