class JiraTeamMetrics::ChartParams
  attr_reader :date_range
  attr_reader :query
  attr_reader :team

  def initialize(values)
    @date_range = values[:date_range]
    @query = values[:query]
    @team = values[:team]
    @filter = values[:filter]
  end

  def self.from_params(params)
    Builder.new(params).build
  end

  class Builder
    def initialize(params)
      @params = params
    end

    def build
      JiraTeamMetrics::ChartParams.new({
        date_range: build_date_range,
        query: build_query,
        team: @params[:team]
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

    def build_query
      query_builder = JiraTeamMetrics::QueryBuilder.new(@params[:query])
      query_builder.and("filter = '#{@params[:filter]}'") unless @params[:filter].blank?
      query_builder.query
    end
  end
end