class JiraTeamMetrics::ChartParams
  attr_reader :date_range
  attr_reader :query

  def initialize(values)
    @date_range = values[:date_range]
    @query = values[:query]
  end

  def self.from_params(board, params)
    if params[:from_date].blank?
      from_date = board.synced_from || Time.now - 90.days
    else
      from_date = Time.parse(params[:from_date])
    end

    if params[:to_date].blank?
      to_date = Time.now
    else
      to_date = Time.parse(params[:to_date])
    end

    date_range = JiraTeamMetrics::DateRange.new(from_date, to_date)

    JiraTeamMetrics::ChartParams.new({
      date_range: date_range,
      query: params[:query]
    })
  end
end