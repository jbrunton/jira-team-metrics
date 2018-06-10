class JiraTeamMetrics::TeamScopeReport
  include JiraTeamMetrics::DescriptiveScopeStatistics

  attr_reader :team
  attr_reader :increment
  attr_reader :epics
  attr_reader :unscoped_epics
  attr_reader :scope
  attr_reader :completed_scope
  attr_reader :remaining_scope
  attr_reader :predicted_scope
  attr_reader :trained_throughput
  attr_reader :trained_epic_scope
  attr_reader :adjusted_throughput
  attr_reader :adjusted_epic_scope
  attr_reader :predicted_throughput
  attr_reader :predicted_epic_scope
  attr_reader :predicted_completion_date
  attr_reader :training_team_reports
  attr_reader :status_color
  attr_reader :status_reason

  def initialize(team, increment, issues, training_team_reports = [])
    @team = team
    @short_team_name = increment.board.domain.short_team_name(team)
    @increment = increment
    @issues = issues
    @training_team_reports = training_team_reports
  end

  def has_training_data?
    @training_team_reports.any?
  end

  def build
    build_scope
    build_predicted_scope if has_training_data?

    analyze_scope
    build_trained_forecasts if has_training_data?
    analyze_status if @increment.target_date

    zero_predicted_scope unless has_training_data?

    self
  end

  def self.issues_for_team(issues, team)
    issues.select do |issue|
      if team == 'None'
        issue.teams.empty?
      else
        issue.teams.include?(team)
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
    if has_training_data?
      # predictive report, so we want to include epics which may not have issues, i.e. those defined through includes relations
      @epics = @issues.select { |issue| issue.is_epic? }
    else
      # training data, so we're more interested in actual issues and epics, regardless of jira hygiene
      @epics = @issues.map { |issue| issue.epic }.compact.uniq
    end
    @unscoped_epics = @epics.select{ |epic| epic.issues(recursive: false).empty? }
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
      status_risk = "at risk, over target by #{over_target_by}% of time remaining"
    else
      @status_color = 'red'
      status_risk = "at risk, over target by #{over_target_by}% of time remaining"
    end
    if use_rolling_forecast?
      @status_reason = "Using rolling forecast. Forecast is #{status_risk}."
    else
      @status_reason = "< 5 issues completed, using predicted forecast. Forecast is #{status_risk}."
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
        predicted_completion_date
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
      (forecast_completion_date - @increment.target_date) / (@increment.target_date - DateTime.now) < 0.2
  end

  def over_target_by
    if forecast_completion_date.nil?
      'Inf'
    else
      (100.0 * (forecast_completion_date - @increment.target_date) / (@increment.target_date - DateTime.now)).round
    end
  end

  def build_predicted_scope
    training_epic_count = @training_team_reports.map { |team_report| team_report.epics.count }.sum.to_f
    training_scope = @training_team_reports.map { |team_report| team_report.scope.count }.sum
    if training_epic_count == 0
      zero_predicted_scope
      return
    end

    @trained_epic_scope = training_scope / training_epic_count
    @adjusted_epic_scope = @increment.metric_adjustments.adjusted_epic_scope(@short_team_name, @trained_epic_scope)
    @predicted_epic_scope = @adjusted_epic_scope || @trained_epic_scope
    @epics.each do |epic|
      build_predicted_scope_for(epic)
    end
  end

  def build_trained_forecasts
    reports_with_completed_scope = @training_team_reports.select { |team_report| team_report.completed_scope.any? }

    if reports_with_completed_scope.any?
      total_completed_scope = reports_with_completed_scope.map { |team_report| team_report.completed_scope.count }.sum
      total_worked_time = reports_with_completed_scope.map { |team_report| team_report.duration_excl_outliers }.sum
      @trained_throughput = total_completed_scope / total_worked_time
    else
      @trained_throughput = 0
    end

    @adjusted_throughput = @increment.metric_adjustments.adjusted_throughput(@short_team_name, @trained_throughput)
    @predicted_throughput = @adjusted_throughput || @trained_throughput

    if @predicted_throughput > 0
      @predicted_completion_date = DateTime.now + (@remaining_scope.count.to_f / @predicted_throughput).days
    end
  end

  def build_predicted_scope_for(epic)
    if epic.issues(recursive: false).empty? && !@predicted_epic_scope.nil?
      @predicted_epic_scope.round.times do |k|
        @scope << JiraTeamMetrics::Issue.new({
          issue_type: 'Story',
          board: epic.board,
          summary: "Predicted scope #{k + 1}",
          fields: { 'Epic Link' => epic.key },
          transitions: [],
          issue_created: DateTime.now.to_date,
          status: 'Predicted'
        })
      end
    end
  end

  def zero_predicted_scope
    @predicted_scope = []
    @trained_throughput = @predicted_throughput = 0.0
    @trained_epic_scope = @predicted_epic_scope = 0.0
  end
end