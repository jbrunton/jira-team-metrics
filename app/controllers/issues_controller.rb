class IssuesController < ApplicationController
  before_action :set_domain
  before_action :set_board

  def show
    @issue = IssueDecorator.new(@board.issues.find{ |i| i.key == params[:issue_key] }, nil, nil)
    if params[:fragment]
      render 'partials/issue', locals: {issue: @issue, show_transitions: true}, layout: false
    end
  end
end