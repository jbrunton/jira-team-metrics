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
    if params[:text]
      @issues = @board.issues.search(params[:text]).first(20)
    elsif params[:mql]
      mql_interpreter = JiraTeamMetrics::MqlInterpreter.new(@board, @board.issues)
      @issues = mql_interpreter.eval(params[:mql])
    end
    respond_to do |format|
      format.json { render json: @issues.map{ |issue| issue.as_json.merge(link: issue_path(issue)) } }
      format.html { render partial: 'partials/issues_list', layout: false }
    end
  end

private
  def set_issue
    @issue = @board.issues.find{ |i| i.key == params[:issue_key] }
  end
end
