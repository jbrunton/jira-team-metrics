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

  def as_string(short_team_name)
    @team_adjustments[short_team_name].to_yaml.gsub("\n", "<br>").html_safe
  end

  def self.parse(yaml_string)
    begin
      adjustments = YAML.load(yaml_string).map do |team, team_adjustments|
        [team, {
          epic_scope: parse_number(team_adjustments['issues_per_epic']),
          throughput: parse_number(team_adjustments['throughput']),
          epic_scope_factor: parse_number(team_adjustments['adjust_issues_per_epic_by']),
          throughput_factor: parse_number(team_adjustments['adjust_throughput_by'])
        }]
      end.to_h
    rescue
      adjustments = {}
    end
    JiraTeamMetrics::MetricAdjustments.new(adjustments)
  end

  PERCENT_REGEX = /^(\d+)+%$/

  def self.parse_number(value)
    if value.class <= Numeric || value.nil?
      value
    else
      begin
        PERCENT_REGEX.match(value)[1].to_f / 100.0
      rescue
        nil
      end
    end
  end
end
