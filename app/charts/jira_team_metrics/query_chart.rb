class JiraTeamMetrics::QueryChart
  def initialize(board, report_params)
    @board = board
    @params = report_params
  end

  def data_table
    interpreter = JiraTeamMetrics::MqlInterpreter.new
    results = interpreter.eval(@params.query, @board, @board.issues)
    results.to_data_table
  end

  def chart_opts
    {
      page: 'enable',
      pageSize: 20,
      cssClassNames: {
      }
    }
  end

  def json_data
    {
      chartOpts: chart_opts,
      data: data_table.to_json
    }
  end
end