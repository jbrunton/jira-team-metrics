class ReportsController < ApplicationController
  before_action :set_domain
  before_action :set_board

  def issues_by_type
  end

  def issues
  end

  def compare
  end

  # get '/:domain/boards/:board_id' do
  #   erb 'boards/show'.to_sym
  # end
  #
  # get '/:domain/boards/:board_id/issues' do
  #   erb 'reports/issues'.to_sym
  # end
  #
  # get '/:domain/boards/:board_id/issues/:issue_key' do
  #   @issue = IssueDecorator.new(@board.issues.find{ |i| i.key == params[:issue_key] }, nil, nil)
  #   if params[:fragment]
  #     erb 'partials/issue'.to_sym, locals: {issue: @issue, show_transitions: true}, layout: false
  #   else
  #     erb 'issues/show'.to_sym
  #   end
  # end
  #

  def control_chart
  end

  #
  # get '/:domain/boards/:board_id/issues_by_type' do
  #   erb '/reports/issues_by_type'.to_sym
  # end
  #
  def cycle_times_by_type
  end

  def timesheets
  end

  def deliveries
    @increments = @board.increments
  end

  def delivery
    @board = Board.find_by(jira_id: @board.jira_id)
    @increment = @board.issues.find_by(key: params[:issue_key])
  end

  def delivery_scope
    @team = params[:team]
    @increment = @board.object.issues.find_by(key: params[:issue_key])

    @report = TeamScopeReport.for(@increment, @team)
    @issues_by_epic = @report.scope
      .group_by{ |issue| issue.epic }
      .sort_by{ |epic, _| epic.nil? ? 1 : 0 }
      .to_h
  end

  def increment_report
    @increment_report ||= IncrementScopeReport.new(@increment).build
  end

  helper_method :cfd_data
  helper_method :team_dashboard_data
  helper_method :increment_report

  def cfd_data(cfd_type)
    ReportFragment.fetch_contents(@increment.board, report_key, "cfd:#{cfd_type}")
  end

  def team_dashboard_data
    ReportFragment.fetch_contents(@increment.board, report_key, "team_dashboard")
  end

  def report_key
    "delivery/#{@increment.key}"
  end
end