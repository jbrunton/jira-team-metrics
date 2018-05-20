class JiraTeamMetrics::ComponentsController < JiraTeamMetrics::ApplicationController
  before_action :set_domain
  before_action :set_board

  def timesheets
    issues = @board.issues.select do |issue|
      issue.in_progress_during?(@chart_params.date_range)
    end
    @filtered_issues = JiraTeamMetrics::MqlInterpreter.new(@board, issues).eval(@chart_params.query)

    epics_by_increment = @filtered_issues
      .group_by{ |issue| issue.increment }
      .sort_by{|increment, _| increment.nil? ? 1 : 0 }
      .map do |increment, issues_for_increment|
        [increment, issues_for_increment.group_by{ |issue| issue.epic }
          .sort_by{|epic, _| epic.nil? ? 1 : 0 }
          .to_h]
      end.to_h

    render 'partials/timesheets', locals: {board: @board, epics_by_increment: epics_by_increment}, layout: false
  end
end