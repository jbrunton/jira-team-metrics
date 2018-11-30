class JiraTeamMetrics::QueryChart
  def initialize(board, report_params)
    @board = board
    @params = report_params
  end

  def data_table
    interpreter = JiraTeamMetrics::MqlInterpreter.new
    results = interpreter.eval(@params.query, @board, @board.issues)
    JiraTeamMetrics::DataTableBuilder.new
      .data(results)
      .pick(:key, :summary, :started_time, :completed_time)
      .build
  end

  def chart_opts
    {
      page: 'enable',
      pageSize: 20
    }
  end

  def json_data
    {
      chartOpts: chart_opts,
      data: data_table.to_json
    }
  end
end