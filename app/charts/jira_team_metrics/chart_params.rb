class JiraTeamMetrics::ChartParams
  attr_reader :date_range
  attr_reader :query
  attr_reader :team

  def initialize(values)
    @date_range = values[:date_range]
    @query = values[:query]
    @team = values[:team]
  end

  def self.from_params(board, params)
    if params[:from_date].blank?
      from_date = (board.synced_from || Time.now - 90.days).to_date
    else
      from_date = Time.parse(params[:from_date]).to_date
    end

    if params[:to_date].blank?
      to_date = Time.now.to_date
    else
      to_date = Time.parse(params[:to_date]).to_date
    end

    date_range = JiraTeamMetrics::DateRange.new(from_date, to_date)

    JiraTeamMetrics::ChartParams.new({
        date_range: date_range,
        query: params[:query],
        team: params[:team]
    })
  end
end