class JiraTeamMetrics::ChartParams
  attr_reader :date_range
  attr_reader :query

  def initialize(values)
    @date_range = values[:date_range]
    @query = values[:query]
  end
end