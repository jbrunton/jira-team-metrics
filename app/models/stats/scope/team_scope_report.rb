class TeamScopeReport
  include DescriptiveScopeStatistics

  attr_reader :epics
  attr_reader :scope
  attr_reader :completed_scope
  attr_reader :remaining_scope
  attr_reader :predicted_scope
  attr_reader :trained_completion_rate
  attr_reader :trained_completion_date

  def initialize(issues, training_issues = [])
    @issues = issues
    @training_issues = training_issues
  end

  def build
    @epics = @issues.select{ |issue| issue.is_epic? }
    @scope = @issues.select{ |issue| issue.is_scope? }

    build_training_report if @training_issues.any?

    issues_by_status_category = @scope.group_by{ |issue| issue.status_category }
    @completed_scope = issues_by_status_category['Done'] || []
    @predicted_scope = issues_by_status_category['Predicted'] || []
    @remaining_scope = (issues_by_status_category['To Do'] || []) +
      (issues_by_status_category['In Progress'] || []) +
      @predicted_scope

    build_trained_forecasts if @training_issues.any?

    self
  end

  def self.for(increment, team)
    issues_for_team = increment.issues(recursive: true).select do |issue|
      (issue.fields['Teams'] || []).include?(team)
    end

    training_issues_for_team = increment.board.training_issues.select do |issue|
      (issue.fields['Teams'] || []).include?(team)
    end

    TeamScopeReport.new(issues_for_team, training_issues_for_team).build
  end

private
  def build_training_report
    @training_scope_report = TeamScopeReport.new(@training_issues).build
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
    if epic.issues(recursive: false).empty? && @training_scope_report
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