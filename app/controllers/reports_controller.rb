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
    @issues_by_increment = @board.issues.group_by { |issue| issue.increment }
  end

  def delivery
    @board = Board.find_by(jira_id: @board.jira_id)
    @increment = @board.issues.find_by(key: params[:issue_key])

    issues = @board.issues.select do |issue|
      increment = issue.increment
      !increment.nil? &&
        increment['issue']['key'] == params[:issue_key] &&
        issue.issue_type != 'Epic'
    end

    @report = ClosureReport.new(issues).build

    @teams = issues.map{ |issue| issue.fields['Teams'] }.compact.flatten.uniq

    @team_reports = @teams.map do |team|
      issues_for_team = issues.select do |issue|
        (issue.fields['Teams'] || []).include?(team)
      end
      [team, ClosureReport.new(issues_for_team).build]
    end.to_h
    @team_reports['None'] = ClosureReport.new(issues.select { |issue| issue.fields['Teams'].nil? }).build
  end

  def delivery_scope
    @team = params[:team]
    @increment = @board.object.issues.find_by(key: params[:issue_key])
    issues_for_team = @increment.issues(recursive: true).select do |issue|
      (issue.fields['Teams'] || []).include?(@team)
    end
    @report = ClosureReport.new(@increment.issues(recursive: true)).build
    @issues_by_epic = issues_for_team
      .group_by{ |issue| issue.epic }
      .sort_by{ |epic, _| epic.nil? ? 1 : 0 }
      .to_h
  end
end