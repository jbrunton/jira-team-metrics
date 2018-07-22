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

  def epic_cfd
    @epic = @board.issues.find_by(key: params[:issue_key]).as_epic
    @rolling_window = params[:rolling_window].to_i
    render json: JiraTeamMetrics::EpicCfdBuilder.new(@epic, @rolling_window).build
  end

private
  def chart_data_for(chart_name)
    chart_class = "JiraTeamMetrics::#{chart_name.to_s.camelize}Chart".constantize
    chart_class.new(@board, @chart_params).json_data
  end
end
