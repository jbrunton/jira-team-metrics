class JiraTeamMetrics::CfdChart
  include JiraTeamMetrics::ChartsHelper

  def initialize(board, report_params)
    @board = board
    @params = report_params
  end

  def data_table
    #interpreter = JiraTeamMetrics::MqlInterpreter.new
    #results = interpreter.eval(@params.query, @board, @board.issues)
    #results.to_data_table

    data_table = JiraTeamMetrics::DataTable.new([
      'Date', 'Total', 'Tooltip', 'Done', 'In Progress', 'To Do'
    ], [])

    data_table.add_row ['Date(2019, 1, 1)', 10, nil, 1, 3, 6]
    data_table.add_row ['Date(2019, 1, 2)', 10, nil, 1, 4, 5]
    data_table.add_row ['Date(2019, 1, 3)', 10, nil, 3, 3, 4]
    data_table.add_row ['Date(2019, 1, 4)', 10, nil, 4, 4, 2]
    data_table.add_row ['Date(2019, 1, 5)', 10, nil, 5, 4, 1]

    data_table
  end

  def chart_opts
    {
      chartArea: {
        width: '90%',
        height: '80%',
        top: '5%'
      },
      height: 500
    }
  end

  def json_data
    {
      chartOpts: chart_opts,
      data: data_table.to_json('Date' => { type: 'date' }, 'Tooltip' => { role: 'tooltip' })
    }
  end

  def build_header
    [
      {'label' => 'Date', 'type' => 'date', 'role' => 'domain'},
      'Total',
      {'type' => 'string', 'role' => 'tooltip'}, # annotation for 'Total'
      'Done',
      'In Progress',
      'To Do'
    ]
  end
end