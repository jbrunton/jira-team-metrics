class JiraTeamMetrics::IssuesController < JiraTeamMetrics::ApplicationController
  include JiraTeamMetrics::ApplicationHelper

  before_action :set_domain
  before_action :set_board
  before_action :set_issue

  def show
    if params[:fragment]
      render partial: 'partials/issue', locals: {issue: @issue, expand: true}, layout: false
    end
  end

  def flag_outlier
    outlier_filter = @board.filters.find_by(name: 'Outliers', filter_type: 'config_filter')
    if params[:outlier]
      outlier_filter.add_issue(@issue)
    else
      outlier_filter.remove_issue(@issue)
    end
  end

  def search
    @issues = @board.issues.search(params[:query]).first(20)
    render json: @issues.map{ |issue| issue.as_json.merge(link: issue_path(issue)) }
  end

private
  def set_issue
    @issue = @board.issues.find{ |i| i.key == params[:issue_key] }
  end
end
