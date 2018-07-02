class JiraTeamMetrics::ComponentsController < JiraTeamMetrics::ApplicationController
  before_action :set_domain
  before_action :set_board

  def timesheets
    issues = @board.issues.select do |issue|
      issue.is_scope? &&
        issue.in_progress_during?(@chart_params.date_range) &&
        issue.duration_in_range(@chart_params.date_range) > 0
    end
    @filtered_issues = JiraTeamMetrics::MqlInterpreter.new(@board, issues).eval(@chart_params.query)

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
end