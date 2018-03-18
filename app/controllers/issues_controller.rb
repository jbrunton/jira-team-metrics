class IssuesController < ApplicationController
  before_action :set_domain
  before_action :set_board

  def show
    @issue = IssueDecorator.new(@board.object.issues.find{ |i| i.key == params[:issue_key] }, nil, nil, nil)
    if params[:fragment]
      render partial: 'partials/issue', locals: {issue: @issue, expand: true}, layout: false
    end
  end
end