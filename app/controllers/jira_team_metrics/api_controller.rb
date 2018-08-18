class JiraTeamMetrics::ApiController < JiraTeamMetrics::ApplicationController
  include JiraTeamMetrics::ApplicationHelper

  before_action :set_domain
  before_action :set_board

  def scatterplot
    render json: chart_data_for(:scatterplot)
  end

  def aging_wip
    render json: chart_data_for(:aging_wip)
  end

  def throughput
    render json: chart_data_for(:throughput)
  end

  def progress_cfd
    @scope = @board.issues.find_by(key: params[:issue_key]).issues(recursive: true).select{ |issue| issue.is_scope? }
    if @report_params.team
      @scope = JiraTeamMetrics::TeamScopeReport.issues_for_team(@scope, @report_params.team)
    end
    if params[:predicted_scope]
      params[:predicted_scope].to_i.times do |k|
        @scope << JiraTeamMetrics::Issue.new({
          issue_type: 'Story',
          board: @board,
          summary: "Predicted scope #{k + 1}",
          transitions: [],
          issue_created: DateTime.now.to_date,
          status: 'Predicted'
        })
      end
    end
    @rolling_window = params[:rolling_window].blank? ? nil : params[:rolling_window].to_i
    render json: JiraTeamMetrics::ScopeCfdBuilder.new(@scope, @rolling_window).build
  end

private
  def chart_data_for(chart_name)
    chart_class = "JiraTeamMetrics::#{chart_name.to_s.camelize}Chart".constantize
    chart_class.new(@board, @report_params).json_data
  end
end
