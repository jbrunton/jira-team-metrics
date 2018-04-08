class IncrementScopeReport < TeamScopeReport
  include DescriptiveScopeStatistics

  attr_reader :epics
  attr_reader :scope
  attr_reader :completed_scope
  attr_reader :remaining_scope
  attr_reader :predicted_scope
  attr_reader :trained_completion_rate

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
    @trained_completion_rate = @team_reports.values.map{ |team_report| team_report.trained_completion_rate }.sum /
      @team_reports.count

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

    if date > Time.now
      adjust_row_with_predictions(row, date)
    end

    row
  end

  def adjust_row_with_predictions(row, date)
    completion_rate = rolling_completion_rate(7)

    change = completion_rate * (date - Time.now) / 1.day
    row.done += change

    if row.predicted > 0
      predicted_change = [row.predicted, change].min
      row.predicted -= predicted_change
      change -= predicted_change
    end

    if row.to_do > 0 && change > 0
      to_do_change = [row.to_do, change].min
      row.to_do -= to_do_change
      change -= to_do_change
    end

    if row.in_progress > 0 && change > 0
      row.in_progress -= change
    end
  end
end