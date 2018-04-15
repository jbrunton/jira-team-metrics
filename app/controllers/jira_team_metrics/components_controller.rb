class JiraTeamMetrics::ComponentsController < JiraTeamMetrics::ApplicationController
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
    epics_by_increment = @board.issues
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