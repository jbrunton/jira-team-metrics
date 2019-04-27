class JiraTeamMetrics::ReportParams
  attr_reader :report_name
  attr_reader :date_range
  attr_reader :query
  attr_reader :filter
  attr_reader :hierarchy_level
  attr_reader :step_interval
  attr_reader :aging_type
  attr_reader :team

  def initialize(board, values)
    @board = board
    @report_name = values[:report_name]
    @date_range = values[:date_range]
    @query = values[:query]
    @filter = values[:filter]
    @hierarchy_level = values[:hierarchy_level] || 'Scope'
    @step_interval = values[:step_interval] || 'Daily'
    @aging_type = values[:aging_type] || 'Total'
    @team = values[:team]
  end

  def self.from_params(board, params)
    Builder.new(board, params).build
  end

  def to_query
    query_builder = JiraTeamMetrics::QueryBuilder.new(@query, :mql)
    query_builder.and("filter('#{@filter}')") unless @filter.blank?
    query_builder.and("hierarchyLevel = '#{@hierarchy_level}'") unless @hierarchy_level.blank?
    query_builder.query
  end

  class Builder
    def initialize(board, params)
      @board = board
      @params = params
    end

    def build
      query = if @params[:report_name].nil?
        @params[:query]
      else
        @board.config.reports.custom_reports.find{ |it| it.name == @params[:report_name] }.query
      end
      JiraTeamMetrics::ReportParams.new(@board,{
        report_name: @params[:report_name],
        date_range: build_date_range,
        query: query,
        filter: @params[:filter],
        hierarchy_level: @params[:hierarchy_level],
        step_interval: @params[:step_interval],
        aging_type: @params[:aging_type],
        team: decode_team
      })
    end

  private

    def build_date_range
      if @params[:from_date].blank?
        from_date = DateTime.now - 30
      else
        from_date = DateTime.parse(@params[:from_date])
      end

      if @params[:to_date].blank?
        to_date = DateTime.now
      else
        to_date = DateTime.parse(@params[:to_date])
      end

      JiraTeamMetrics::DateRange.new(
        from_date.at_beginning_of_day,
        to_date.at_beginning_of_day)
    end

    def decode_team
      CGI::unescape(@params[:team]) unless @params[:team].nil?
    end
  end
end