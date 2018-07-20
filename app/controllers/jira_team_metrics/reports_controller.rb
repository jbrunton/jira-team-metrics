class JiraTeamMetrics::ReportsController < JiraTeamMetrics::ApplicationController
  before_action :set_domain
  before_action :set_board

  def timesheets
  end

  def throughput
  end

  def projects
    @projects = @board.projects
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
    mql_interpreter = JiraTeamMetrics::MqlInterpreter.new(@board, @board.epics)
    @sections = @domain.config.epics_report_options.sections.map do |section|
      {
        title: section.title,
        epics: mql_interpreter.eval(section.mql)
      }
    end
  end

  def epic
    @epic = @board.issues.find_by(key: params[:issue_key]).as_epic
  end

  def scatterplot
  end

  def aging_wip
  end

  def project_scope
    @team = params[:team]
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
  end

  def project_throughput
    @team = params[:team]
    @project = @board.issues.find_by(key: params[:issue_key])
  end

  def project_report
    @project_report ||= JiraTeamMetrics::ProjectScopeReport.new(@project).build
  end

  helper_method :project_cfd_data
  helper_method :epic_cfd_data
  helper_method :team_dashboard_data
  helper_method :project_report

  def project_cfd_data(cfd_type)
    JiraTeamMetrics::ReportFragment.fetch_contents(@project.board, report_key, "cfd:#{cfd_type}")
  end

  def epic_cfd_data
    JiraTeamMetrics::EpicCfdBuilder.new(@epic).build
  end

  def team_dashboard_data
    JiraTeamMetrics::ReportFragment.fetch_contents(@project.board, report_key, "team_dashboard")
  end

  def report_key
    "project/#{@project.key}"
  end
end