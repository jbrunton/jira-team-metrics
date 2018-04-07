class IncrementScopeReport < TeamScopeReport
  include DescriptiveScopeStatistics

  attr_reader :epics
  attr_reader :scope
  attr_reader :completed_scope
  attr_reader :remaining_scope
  attr_reader :predicted_scope

  attr_reader :teams

  def initialize(increment)
    @increment = increment
  end

  def build
    increment_issues = @increment.issues(recursive: true)

    @teams = increment_issues.map{ |issue| issue.fields['Teams'] }.compact.flatten.uniq
    @team_reports = @teams.map do |team|
      [team, TeamScopeReport.for(@increment, team)]
    end.to_h
    @team_reports['None'] = TeamScopeReport.new(increment_issues.select { |issue| issue.fields['Teams'].nil? }).build

    @epics = increment_issues.select{ |issue| issue.is_epic? }
    @scope = @team_reports.values.map{ |team_report| team_report.scope }.flatten.uniq
    @completed_scope = @team_reports.values.map{ |team_report| team_report.completed_scope }.flatten.uniq
    @predicted_scope = @team_reports.values.map{ |team_report| team_report.predicted_scope }.flatten.uniq
    @remaining_scope = @team_reports.values.map{ |team_report| team_report.remaining_scope }.flatten.uniq

    self
  end

  def team_report_for(team)
    @team_reports[team]
  end

  def cfd_data
    data = [['Day', 'Done', 'In Progress', 'To Do', 'Predicted']]
    dates = DateRange.new(started_date, rolling_forecast_completion_date(7) || Time.now + 90.days).to_a
    dates.each_with_index do |date, index|
      data << cfd_row_for(date).to_array(index)
    end
    data
  end

  CfdRow = Struct.new(:predicted, :to_do, :in_progress, :done) do
    def to_array(index)
      [index, done, in_progress, to_do, predicted]
    end
  end

private
  def cfd_row_for(date)
    row = CfdRow.new(0, 0, 0, 0)

    scope.each do |issue|
      case issue.status_category_on(date)
        when 'To Do'
          row.to_do += 1
        when 'In Progress'
          row.in_progress += 1
        when 'Done'
          row.done += 1
        when 'Predicted'
          row.predicted += 1
      end
    end

    row
  end
end