class ComponentsController < ApplicationController
  before_action :set_domain
  before_action :set_board
  # get '/:domain/boards/:board_id/summary' do
  #   erb 'boards/summary'.to_sym, layout: false, locals: { group_by: params[:group_by] }
  # end
  #
  # get '/:domain/boards/:board_id/issues_list' do
  #   erb 'partials/table'.to_sym, :locals => { :table => @board.issues_table }, layout: false
  # end

  def wip
    date = Time.parse(params[:date])
    issues = @board.wip_on_date(date)
    render 'partials/wip'.to_sym, locals: {date: date, issues: issues}, layout: false
  end
end