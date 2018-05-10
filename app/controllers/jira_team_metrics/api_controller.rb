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

private
  def chart_data_for(chart_name)
    chart_params = JiraTeamMetrics::ChartParams.new(
      query: params[:query],
      date_range: JiraTeamMetrics::DateRange.new(params[:from_date], params[:to_date])
    )
    chart_class = "JiraTeamMetrics::#{chart_name.to_s.camelize}Chart".constantize
    chart_class.new(@board, chart_params).json_data
  end
end
