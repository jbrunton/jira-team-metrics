class ReportsController < ApplicationController
  before_action :set_domain
  before_action :set_board

  def issues_by_type

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
  # get '/:domain/boards/:board_id/control_chart' do
  #   erb 'reports/control_chart'.to_sym
  # end
  #
  # get '/:domain/boards/:board_id/issues_by_type' do
  #   erb '/reports/issues_by_type'.to_sym
  # end
  #
  # get '/:domain/boards/:board_id/cycle_times_by_type' do
  #   erb '/reports/cycle_times_by_type'.to_sym
  # end
end