class JiraTeamMetrics::TeamScopeReport
  include JiraTeamMetrics::DescriptiveScopeStatistics

  attr_reader :team
  attr_reader :epics
  attr_reader :scope
  attr_reader :completed_scope
  attr_reader :remaining_scope
  attr_reader :predicted_scope
  attr_reader :trained_completion_rate
  attr_reader :trained_completion_date
  attr_reader :trained_issues_per_epic
  attr_reader :status_color
  attr_reader :status_reason

  def initialize(team, increment, issues, training_team_reports = nil)
    @team = team
    @increment = increment
    @issues = issues
    @training_team_reports = training_team_reports
  end

  def build
    build_scope
    build_predicted_scope unless @training_team_reports.nil?

    analyze_scope
    build_trained_forecasts unless @training_team_reports.nil?
    analyze_status if @increment.target_date

    self
  end

  def self.issues_for_team(issues, team)
    issues.select do |issue|
      if team == 'None'
        (issue.fields['Teams'] || []).empty?
      else
        (issue.fields['Teams'] || []).include?(team)
      end
    end
  end

  def self.for(increment, team)
    issues_for_team = self.issues_for_team(increment.issues(recursive: true), team)

    training_team_reports = increment.board.training_increments.map do |training_increment|
      training_issues_for_team = self.issues_for_team(training_increment.issues(recursive: true), team)
      JiraTeamMetrics::TeamScopeReport.new(team, training_increment, training_issues_for_team).build
    end

    JiraTeamMetrics::TeamScopeReport.new(team, increment, issues_for_team, training_team_reports).build
  end

private
  def build_scope
    if @training_team_reports.nil?
      # training data, so we're more interested in actual issues and epics, regardless of jira hygiene
      @epics = @issues.map { |issue| issue.epic }.compact.uniq
    else
      # predictive report, so we want to include epics which may not have issues, i.e. those defined through includes relations
      @epics = @issues.select { |issue| issue.is_epic? }
    end

    @scope = @issues.select { |issue| issue.is_scope? }
  end

  def analyze_scope
    issues_by_status_category = @scope.group_by{ |issue| issue.status_category }
    @completed_scope = issues_by_status_category['Done'] || []
    @predicted_scope = issues_by_status_category['Predicted'] || []
    @remaining_scope = (issues_by_status_category['To Do'] || []) +
      (issues_by_status_category['In Progress'] || []) +
      @predicted_scope
  end

  def analyze_status
    if done?
      @status_color = 'blue'
      @status_reason = "Done."
    else
      analyze_progress
    end
  end

  def analyze_progress
    if on_track?
      @status_color = 'green'
      status_risk = 'on target'
    elsif at_risk?
      @status_color = 'yellow'
      status_risk = 'at risk, over target by < 20% of time remaining'
    else
      @status_color = 'red'
      status_risk = 'at risk, over target by > 20% of time remaining'
    end
    if use_rolling_forecast?
      @status_reason = "Using rolling forecast. Forecast is #{status_risk}."
    else
      @status_reason = "< 5 issues completed, using trained forecast. Forecast is #{status_risk}."
    end
  end

  def use_rolling_forecast?
    completed_scope.count >= 5
  end

  def forecast_completion_date
    @forecast_completion_date ||= begin
      if use_rolling_forecast?
        rolling_forecast_completion_date(@increment.board.config.rolling_window_days)
      else
        trained_completion_date
      end
    end
  end

  def done?
    @remaining_scope.empty?
  end

  def on_track?
    forecast_completion_date &&
      forecast_completion_date <= @increment.target_date
  end

  def at_risk?
    forecast_completion_date &&
      (forecast_completion_date - @increment.target_date) / (@increment.target_date - Time.now) < 0.2
  end

  def build_predicted_scope
    training_epic_count = @training_team_reports.map { |team_report| team_report.epics.count }.sum.to_f
    training_scope = @training_team_reports.map { |team_report| team_report.scope.count }.sum
    return if training_epic_count == 0

    @trained_issues_per_epic = training_scope / training_epic_count
    @epics.each do |epic|
      build_predicted_scope_for(epic)
    end
  end

  def build_trained_forecasts
    reports_with_completed_scope = @training_team_reports.select { |team_report| team_report.completed_scope.any? }

    if reports_with_completed_scope.any?
      total_completed_scope = reports_with_completed_scope.map { |team_report| team_report.completed_scope.count }.sum
      total_worked_time = reports_with_completed_scope.map { |team_report| team_report.duration_excl_outliers }.sum
      @trained_completion_rate = total_completed_scope / total_worked_time
    else
      @trained_completion_rate = 0
    end

    if @trained_completion_rate > 0
      @trained_completion_date = Time.now + (@remaining_scope.count.to_f / @trained_completion_rate).days
    end
  end

  def build_predicted_scope_for(epic)
    if epic.issues(recursive: false).empty? && !@trained_issues_per_epic.nil?
      @trained_issues_per_epic.round.times do |k|
        @scope << JiraTeamMetrics::Issue.new({
          issue_type: 'Story',
          board: epic.board,
          summary: "Predicted scope #{k + 1}",
          fields: { 'Epic Link' => epic.key },
          transitions: [],
          issue_created: Time.now.to_date,
          status: 'Predicted'
        })
      end
    end
  end
end