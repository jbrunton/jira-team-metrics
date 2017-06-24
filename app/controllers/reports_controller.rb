class ReportsController < ApplicationController
  helpers DomainsHelper

  before ('/:domain*') { set_domain(params) }
  before ('/:domain/boards/:board_id*') { set_board(params) }

  get '/:domain/boards/:board_id' do
    erb 'boards/show'.to_sym
  end

  get '/:domain/boards/:board_id/issues' do
    erb 'boards/issues'.to_sym
  end

  get '/:domain/boards/:board_id/issues/:issue_key' do
    @issue = IssueDecorator.new(@board.issues.find{ |i| i.key == params[:issue_key] }, nil, nil)
    if params[:fragment]
      erb 'partials/issue'.to_sym, locals: {issue: @issue, show_transitions: true}, layout: false
    else
      erb 'issues/show'.to_sym
    end
  end

  get '/:domain/boards/:board_id/control_chart' do
    erb 'boards/control_chart'.to_sym
  end
end