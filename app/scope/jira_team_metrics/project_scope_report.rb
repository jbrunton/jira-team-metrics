class JiraTeamMetrics::ProjectScopeReport < JiraTeamMetrics::TeamScopeReport
  include JiraTeamMetrics::DescriptiveScopeStatistics
  include JiraTeamMetrics::ChartsHelper



  attr_reader :project
  attr_reader :epics
  attr_reader :unscoped_epics
  attr_reader :scope
  attr_reader :completed_scope
  attr_reader :remaining_scope
  attr_reader :predicted_scope
  attr_reader :predicted_throughput
  attr_reader :predicted_completion_date

  attr_reader :teams

  def initialize(project)
    @project = project
  end

  def build
    project_issues = @project.issues(recursive: true)

    @teams = project_issues.map{ |issue| issue.fields['Teams'] }.compact.flatten.uniq + ['None']
    @team_reports = @teams.map do |team|
      [team, JiraTeamMetrics::TeamScopeReport.for(@project, team)]
    end.to_h
    @team_reports['None'] = JiraTeamMetrics::TeamScopeReport.for(@project, 'None').build

    @epics = project_issues.select{ |issue| issue.is_epic? }
    @unscoped_epics = @epics.select{ |epic| epic.issues(recursive: false).empty? }
    @scope = @team_reports.values.map{ |team_report| team_report.scope }.flatten.uniq
    @completed_scope = @team_reports.values.map{ |team_report| team_report.completed_scope }.flatten.uniq
    @predicted_scope = @team_reports.values.map{ |team_report| team_report.predicted_scope }.flatten.uniq
    @remaining_scope = @team_reports.values.map{ |team_report| team_report.remaining_scope }.flatten.uniq
    predicted_throughputs = @team_reports.values.map{ |team_report| team_report.predicted_throughput }.compact
    @predicted_throughput = predicted_throughputs.empty? ? 0 : predicted_throughputs.sum
    if @predicted_throughput > 0
      @predicted_completion_date = DateTime.now + @remaining_scope.count.to_f / @predicted_throughput
    end

    self
  end

  def team_report_for(team)
    @team_reports[team]
  end

  def cfd_data(cfd_type)
    JiraTeamMetrics::ProjectCfdBuilder.new(self).build(cfd_type)
  end
end