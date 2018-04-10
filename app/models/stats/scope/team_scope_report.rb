class TeamScopeReport
  include DescriptiveScopeStatistics

  attr_reader :epics
  attr_reader :scope
  attr_reader :completed_scope
  attr_reader :remaining_scope
  attr_reader :predicted_scope
  attr_reader :trained_completion_rate
  attr_reader :trained_completion_date
  attr_reader :status_color

  def initialize(increment, issues, training_issues = nil)
    @increment = increment
    @issues = issues
    @training_issues = training_issues
  end

  def build
    @epics = @issues.select{ |issue| issue.is_epic? }
    @scope = @issues.select{ |issue| issue.is_scope? }

    build_training_report unless @training_issues.nil?
    analyze_scope
    analyze_status if @increment.target_date
    build_trained_forecasts unless @training_issues.nil?

    self
  end

  def self.for(increment, team)
    issues_for_team = increment.issues(recursive: true).select do |issue|
      if team == 'None'
        (issue.fields['Teams'] || []).empty?
      else
        (issue.fields['Teams'] || []).include?(team)
      end
    end

    training_issues_for_team = increment.board.training_issues.select do |issue|
      if team == 'None'
        (issue.fields['Teams'] || []).empty?
      else
        (issue.fields['Teams'] || []).include?(team)
      end
    end

    TeamScopeReport.new(increment, issues_for_team, training_issues_for_team).build
  end

private

  def analyze_scope
    issues_by_status_category = @scope.group_by{ |issue| issue.status_category }
    @completed_scope = issues_by_status_category['Done'] || []
    @predicted_scope = issues_by_status_category['Predicted'] || []
    @remaining_scope = (issues_by_status_category['To Do'] || []) +
      (issues_by_status_category['In Progress'] || []) +
      @predicted_scope
  end

  def analyze_status
    forecast_completion_date = rolling_forecast_completion_date(7)
    if on_track?(forecast_completion_date)
      @status_color = 'light-blue'
    elsif at_risk?(forecast_completion_date)
      @status_color = 'yellow'
    else
      @status_color = 'red'
    end
  end

  def on_track?(forecast_completion_date)
    @remaining_scope.empty? || (forecast_completion_date &&
      forecast_completion_date <= @increment.target_date)
  end

  def at_risk?(forecast_completion_date)
    forecast_completion_date &&
      (forecast_completion_date - @increment.target_date) / (@increment.target_date - Time.now) < 0.2
  end

  def build_training_report
    @training_scope_report = TeamScopeReport.new(@increment, @training_issues).build
    @epics.each do |epic|
      build_predicted_scope_for(epic)
    end
  end

  def build_trained_forecasts
    @trained_completion_rate = @training_scope_report.completion_rate
    if @trained_completion_rate > 0
      @trained_completion_date = Time.now + (@remaining_scope.count.to_f / @trained_completion_rate).days
    end
  end

  def build_predicted_scope_for(epic)
    if epic.issues(recursive: false).empty? && @training_scope_report.scope.any?
      @training_scope_report.issues_per_epic.round.times do |k|
        @scope << Issue.new({
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