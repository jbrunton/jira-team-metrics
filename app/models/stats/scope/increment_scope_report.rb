class IncrementScopeReport < TeamScopeReport
  include DescriptiveScopeStatistics
  include ChartsHelper



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

    CfdBuilder.new(@scope).build(self, cfd_type)
  end

  def timeline_data(cfd_type)
    data = [[{ 'type' => 'string', 'id' => 'Index' }, { 'type' => 'string', 'id' => 'Team' }, { 'type' => 'date', 'id' => 'Start' }, { 'type' => 'date', 'id' => 'End' }]]
    index = 1
    @team_reports.each do |team, team_report|
      started_date = team_report.started_date || Time.now
      case cfd_type
        when :raw
          forecast_date = team_report.rolling_forecast_completion_date(7)
        when :trained
          forecast_date = team_report.trained_completion_date
        else
          raise "Unexpected cfd_type: #{cfd_type}"
      end
      unless forecast_date.nil?
        data << [index, team.upcase, date_as_string(started_date), date_as_string(forecast_date)]
        index = index + 1
      end
    end
    data
  end
end