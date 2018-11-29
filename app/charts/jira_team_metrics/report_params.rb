class JiraTeamMetrics::ReportParams
  attr_reader :date_range
  attr_reader :query
  attr_reader :filter
  attr_reader :hierarchy_level
  attr_reader :step_interval
  attr_reader :team

  def initialize(values)
    @date_range = values[:date_range]
    @query = values[:query]
    @filter = values[:filter]
    @hierarchy_level = values[:hierarchy_level] || 'Scope'
    @step_interval = values[:step_interval] || 'Daily'
    @team = values[:team]
  end

  def self.from_params(params)
    Builder.new(params).build
  end

  def to_query
    query_builder = JiraTeamMetrics::QueryBuilder.new(@query, :mql)
    query_builder.and("filter('#{@filter}')") unless @filter.blank?
    query_builder.and("hierarchyLevel = '#{@hierarchy_level}'") unless @hierarchy_level.blank?
    query_builder.query
  end

  class Builder
    def initialize(params)
      @params = params
    end

    def build
      JiraTeamMetrics::ReportParams.new({
        date_range: build_date_range,
        query: @params[:query],
        filter: @params[:filter],
        hierarchy_level: @params[:hierarchy_level],
        step_interval: @params[:step_interval],
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