class JiraTeamMetrics::ReportsController < JiraTeamMetrics::ApplicationController
  before_action :set_domain
  before_action :set_board

  include JiraTeamMetrics::PathHelper

  def timesheets
  end

  def throughput
    @default_query = @board.config.reports.throughput.default_query
  end

  def projects
    @sections = sections_for(@board.projects, @board.config.reports.projects)
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

  def refresh
    @project = @board.issues.find_by(key: params[:issue_key])
    JiraTeamMetrics::RefreshReportJob.perform_now(@board.jira_id, @project.key, @domain)
    redirect_to project_report_path(@project)
  end

  def project_histories
    @project = @board.issues.find_by(key: params[:issue_key])
    @report_fragments = JiraTeamMetrics::ReportFragment.includes(:sync_history)
      .fragment_histories(@board.jira_id, report_key, 'team_dashboard')
      .map { |fragment| fragment }
  end

  def epics
    @report_options = @board.config.reports.epics
    binding.pry
    @sections = sections_for(@board.epics, @report_options)
  end

  def epic
    @epic = @board.issues.find_by(key: params[:issue_key]).as_epic
    @forecaster = @epic.forecaster
    @progress_summary_url = epic_progress_summary_path(@epic)
    @progress_cfd_url = epic_cfd_path(@epic)
  end

  def scatterplot
    @default_query = @board.config.reports.scatterplot.default_query
  end

  def aging_wip
  end

  def cfd
  end

  def query
    @query = @report_params.query || @default_query
  end

  def project_scope
    @team = @report_params.team
    @project = @board.issues.find_by(key: params[:issue_key])

    @report = JiraTeamMetrics::TeamScopeReport.for(@project, @team)
    @issues_by_epic = build_issues_by_epic(@report)

    @quicklinks = build_quicklinks

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
  helper_method :team_dashboard_timestamp
  helper_method :project_report

  def project_cfd_data(cfd_type)
    JiraTeamMetrics::ReportFragment.fetch_contents(@board.jira_id, report_key, "cfd:#{cfd_type}", params[:history_id])
  end

  def epic_cfd_data
    JiraTeamMetrics::ScopeCfdBuilder.new(@epic).build
  end

  def team_dashboard_timestamp
    JiraTeamMetrics::ReportFragment.fetch(@board.jira_id, report_key_for(@project), "team_dashboard", params[:history_id]).updated_at
  end

  def team_dashboard_data
    team_dashboard_data_for(@project)
  end

  def team_dashboard_data_for(project)
    JiraTeamMetrics::ReportFragment.fetch_contents(@board.jira_id, report_key_for(project), "team_dashboard", params[:history_id])
  end

  def report_key
    report_key_for(@project)
  end

  def report_key_for(project)
    "project/#{project.key}"
  end

private
  def sections_for(issues, report_options)
    backing_interpreter = JiraTeamMetrics::MqlInterpreter.new
    backing_issues = backing_interpreter.eval(report_options.backing_query, @board, issues).rows
    sections_interpreter = JiraTeamMetrics::MqlInterpreter.new
    if report_options.sections.any?
      report_options.sections.map do |section|
        epics = sections_interpreter.eval(section.mql, @board, backing_issues).rows
        invalid_wip = !section.min.nil? && epics.count < section.min
        {
          title: section.title,
          issues: epics,
          collapsed: section.collapsed,
          min: section.min,
          max: section.max,
          invalid_wip: invalid_wip
        }
      end
    else
      [{
        title: 'In Progress',
        issues: issues
      }]
    end
  end

  def build_issues_by_epic(report)
    issues_by_epic = report.scope
      .group_by{ |issue| issue.epic if issue.epic.try(:project) == @project }

    empty_epics = @report.epics
      .select{ |epic| !issues_by_epic.keys.include?(epic) }

    empty_epics.each { |epic| issues_by_epic[epic] = [] }

    issues_by_epic
      .sort_by{ |epic, _| epic.nil? ? 1 : 0 }
      .to_h
  end

  def build_quicklinks
    query = "project = '#{@project.key}' and Teams includes '#{@team}'"
    opts = {
        from_date: @report.started_date.at_beginning_of_month,
        to_date: @report.completed_date.at_beginning_of_month + 2.months,
        query: query
    }
    issues_by_month_link = JiraTeamMetrics::QuicklinkBuilder.throughput_quicklink(@board, opts.merge(hierarchy_level: 'Scope'))
    epics_by_month_link = JiraTeamMetrics::QuicklinkBuilder.throughput_quicklink(@board, opts.merge(hierarchy_level: 'Epic'))
    issues_scatterplot_link = JiraTeamMetrics::QuicklinkBuilder.scatterplot_quicklink(@board, opts.merge(hierarchy_level: 'Scope'))
    epics_scatterplot_link = JiraTeamMetrics::QuicklinkBuilder.scatterplot_quicklink(@board, opts.merge(hierarchy_level: 'Epic'))
    issues_cfd_link = JiraTeamMetrics::QuicklinkBuilder.cfd_quicklink(@board, opts.merge(hierarchy_level: 'Scope'))
    epics_cfd_link = JiraTeamMetrics::QuicklinkBuilder.cfd_quicklink(@board, opts.merge(hierarchy_level: 'Epic'))
    {
      'Throughput Reports' => {
        'Issues by Month' => issues_by_month_link,
        'Epics by Month' => epics_by_month_link
      },
      'Cycle Time Reports' => {
        'Issue Cycle Times' => issues_scatterplot_link,
        'Epic Cycle Times' => epics_scatterplot_link
      },
      'CFD Reports' => {
        'Issues CFD' => issues_cfd_link,
        'Epics CFD' => epics_cfd_link
      }
    }
  end
end