class JiraTeamMetrics::ReportsController < JiraTeamMetrics::ApplicationController
  before_action :set_domain
  before_action :set_board

  include JiraTeamMetrics::PathHelper

  def timesheets
  end

  def throughput
  end

  def projects
    @sections = sections_for(@board.projects, @domain.config.projects_report_options)
  end

  def project
    @project = @board.issues.find_by(key: params[:issue_key])
    if (params[:show_teams] || params[:filter_teams]).nil?
      @show_teams = team_dashboard_data[:teams].map do |team, _|
        @domain.short_team_name(team)
      end
      @filter_applied = false
    else
      @show_teams = (params[:show_teams] || params[:filter_teams]).split(',')
      @filter_applied = true
    end
  end

  def epics
    @sections = sections_for(@board.epics, @domain.config.epics_report_options)
  end

  def epic
    @epic = @board.issues.find_by(key: params[:issue_key]).as_epic
    @forecaster = @epic.forecaster
    @progress_summary_url = epic_progress_summary_path(@epic)
    @progress_cfd_url = epic_cfd_path(@epic)
  end

  def scatterplot
  end

  def aging_wip
  end

  def project_scope
    @team = @report_params.team
    @project = @board.issues.find_by(key: params[:issue_key])

    @report = JiraTeamMetrics::TeamScopeReport.for(@project, @team)
    @issues_by_epic = @report.scope
      .group_by{ |issue| issue.epic }
      .sort_by{ |epic, _| epic.nil? ? 1 : 0 }
      .to_h

    @status_categories = ['To Do', 'In Progress', 'Done', 'Predicted']
    if params[:filter_status].nil?
      @show_categories = @status_categories
      @filter_applied = false
    else
      @show_categories = params[:filter_status].split(',')
      @filter_applied = true
    end
    @forecaster = JiraTeamMetrics::Forecaster.new(@report.scope)
    @progress_summary_url = project_progress_summary_path(@project, @team)
    @progress_cfd_url = project_cfd_path(@project, @team)
  end

  def project_throughput
    @team = @report_params.team
    @project = @board.issues.find_by(key: params[:issue_key])
  end

  def project_report
    @project_report ||= JiraTeamMetrics::ProjectScopeReport.new(@project).build
  end

  helper_method :project_cfd_data
  helper_method :epic_cfd_data
  helper_method :team_dashboard_data
  helper_method :team_dashboard_data_for
  helper_method :project_report

  def project_cfd_data(cfd_type)
    JiraTeamMetrics::ReportFragment.fetch_contents(@project.board, report_key, "cfd:#{cfd_type}")
  end

  def epic_cfd_data
    JiraTeamMetrics::ScopeCfdBuilder.new(@epic).build
  end

  def team_dashboard_data
    team_dashboard_data_for(@project)
  end

  def team_dashboard_data_for(project)
    JiraTeamMetrics::ReportFragment.fetch_contents(project.board, report_key_for(project), "team_dashboard")
  end

  def report_key
    report_key_for(@project)
  end

  def report_key_for(project)
    "project/#{project.key}"
  end

private
  def sections_for(issues, report_options)
    mql_interpreter = JiraTeamMetrics::MqlInterpreter.new(@board, issues)
    if report_options.sections.any?
      report_options.sections.map do |section|
        {
          title: section.title,
          issues: mql_interpreter.eval(section.mql),
          collapsed: section.collapsed
        }
      end
    else
      [{
        title: 'In Progress',
        issues: issues
      }]
    end
  end
end