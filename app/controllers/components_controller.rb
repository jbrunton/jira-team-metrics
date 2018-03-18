class ComponentsController < ApplicationController
  before_action :set_domain
  before_action :set_board
  # get '/:domain/boards/:board_id/summary' do
  #   erb 'boards/summary'.to_sym, layout: false, locals: { group_by: params[:group_by] }
  # end
  #
  def issues_list
    render 'partials/_table', :locals => { :table => @board.issues_table }, layout: false
  end

  def wip
    date = Time.parse(params[:date])
    issues = @board.wip_on_date(date)
    render 'partials/wip', locals: {date: date, issues: issues}, layout: false
  end

  def timesheets
    issues_by_epic = @board.issues.group_by{ |issue| issue.epic }
    render 'partials/timesheets', locals: {issues_by_epic: issues_by_epic}, layout: false
  end
end