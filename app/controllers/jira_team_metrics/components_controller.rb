class JiraTeamMetrics::ComponentsController < JiraTeamMetrics::ApplicationController
  before_action :set_domain
  before_action :set_board

  def timesheets
    issues = @board.issues.select do |issue|
        issue.in_progress_during?(@report_params.date_range) &&
        issue.duration_in_range(@report_params.date_range) > 0
    end
    @filtered_issues = JiraTeamMetrics::MqlInterpreter.new(@board, issues).eval(@report_params.to_query)

    epics_by_project = @filtered_issues
      .group_by{ |issue| issue.project }
      .sort_by{|project, _| project.nil? ? 1 : 0 }
      .map do |project, issues_for_project|
        [project, issues_for_project.group_by{ |issue| issue.epic }
          .sort_by{|epic, _| epic.nil? ? 1 : 0 }
          .to_h]
      end.to_h

    render 'partials/timesheets', locals: {board: @board, epics_by_project: epics_by_project}, layout: false
  end

  def progress_summary
    @scope = @board.issues.find_by(key: params[:issue_key]).issues(recursive: true).select{ |issue| issue.is_scope? }
    if @report_params.team
      @scope = JiraTeamMetrics::TeamScopeReport.issues_for_team(@scope, @report_params.team)
    end
    if params[:predicted_scope]
      params[:predicted_scope].to_i.times do |k|
        @scope << JiraTeamMetrics::Issue.new({
          issue_type: 'Story',
          board: @board,
          summary: "Predicted scope #{k + 1}",
          transitions: [],
          issue_created: DateTime.now.to_date,
          status: 'Predicted'
        })
      end
    end
    @forecaster = JiraTeamMetrics::Forecaster.new(@scope)
    @rolling_window = params[:rolling_window].blank? ? nil : params[:rolling_window].to_i
    render partial: 'partials/progress_summary'
  end
end