class IncrementScopeReport < TeamScopeReport
  include DescriptiveScopeStatistics

  attr_reader :epics
  attr_reader :scope
  attr_reader :completed_scope
  attr_reader :remaining_scope
  attr_reader :predicted_scope
  attr_reader :trained_completion_rate
  attr_reader :trained_completion_date

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
    @team_reports['None'] = TeamScopeReport.new(@increment, increment_issues.select { |issue| issue.fields['Teams'].nil? }).build

    @epics = increment_issues.select{ |issue| issue.is_epic? }
    @scope = @team_reports.values.map{ |team_report| team_report.scope }.flatten.uniq
    @completed_scope = @team_reports.values.map{ |team_report| team_report.completed_scope }.flatten.uniq
    @predicted_scope = @team_reports.values.map{ |team_report| team_report.predicted_scope }.flatten.uniq
    @remaining_scope = @team_reports.values.map{ |team_report| team_report.remaining_scope }.flatten.uniq
    @trained_completion_rate = @team_reports.values.map{ |team_report| team_report.trained_completion_rate }.sum
    if @trained_completion_rate > 0
      @trained_completion_date = Time.now + (@remaining_scope.count.to_f / @trained_completion_rate).days
    end

    self
  end

  def team_report_for(team)
    @team_reports[team]
  end

  def cfd_data(cfd_type)
    case cfd_type
      when :raw
        completion_rate = rolling_completion_rate(7)
        completion_date = rolling_forecast_completion_date(7)
      when :trained
        completion_rate = trained_completion_rate
        completion_date = trained_completion_date
      else
        raise "Unexpected cfd_type: #{cfd_type}"
    end

    CfdBuilder.new(@scope).build(started_date, completion_rate, completion_date)
  end
end