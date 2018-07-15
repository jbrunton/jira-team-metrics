class JiraTeamMetrics::StatusAnalyzer
  attr_reader :status_color
  attr_reader :status_reason

  def initialize(team_report)
    @team_report = team_report
  end

  def analyze
    if done?
      @status_color = 'blue'
      @status_reason = 'Done.'
    elsif late?
      @status_color = 'red'
      @status_reason = 'Target date is in the past.'
    else
      analyze_progress
    end
    self
  end

private
  def analyze_progress
    if on_track?
      @status_color = 'green'
      status_risk = 'on target'
    elsif at_risk?
      @status_color = 'yellow'
      status_risk = "at risk, over target by #{over_target_by}% of time remaining"
    else
      @status_color = 'red'
      status_risk = "at risk, over target by #{over_target_by}% of time remaining"
    end
    if @team_report.use_rolling_forecast?
      @status_reason = "Using rolling forecast. Forecast is #{status_risk}."
    else
      @status_reason = "< 5 issues completed, using predicted forecast. Forecast is #{status_risk}."
    end
  end

  def done?
    remaining_scope.empty?
  end

  def on_track?
    forecast_completion_date &&
      forecast_completion_date <= project.target_date
  end

  def at_risk?
    forecast_completion_date &&
      (forecast_completion_date - project.target_date) / (project.target_date - DateTime.now) < 0.2
  end

  def over_target_by
    if forecast_completion_date.nil?
      'Inf'
    else
      (100.0 * (forecast_completion_date - project.target_date) / (project.target_date - DateTime.now)).round
    end
  end

  def late?
    !done? && project.target_date < DateTime.now
  end

  def completed_scope
    @team_report.completed_scope
  end

  def remaining_scope
    @team_report.remaining_scope
  end

  def forecast_completion_date
    @team_report.forecast_completion_date
  end

  def project
    @team_report.project
  end
end
