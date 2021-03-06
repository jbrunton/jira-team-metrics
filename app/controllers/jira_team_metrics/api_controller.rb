require 'csv'

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

  def cfd
    render json: chart_data_for(:cfd)
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

  def query
    respond_to do |format|
      format.json do
        begin
          render json: chart_data_for(:query)
        rescue Parslet::ParseFailed => e
          syntax_error(e)
        rescue JiraTeamMetrics::ParserError => e
          parser_error(e)
        end
      end
      format.csv do
        data_table = chart_for(:query).data_table
        render plain: data_table.to_csv
      end
    end
  end

private
  def chart_for(chart_name)
    chart_class = "JiraTeamMetrics::#{chart_name.to_s.camelize}Chart".constantize
    chart_class.new(@board, @report_params)
  end

  def chart_data_for(chart_name)
    chart_for(chart_name).json_data
  end

  def syntax_error(exception)
    render status: :bad_request, json: {
      error: 'syntax_error',
      message: 'Syntax Error',
      details: exception.parse_failure_cause.ascii_tree
    }
  end

  def parser_error(exception)
    render status: :bad_request, json: {
      error: 'runtime_error',
      message: 'Runtime Error',
      details: exception.message
    }
  end
end
