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

    data_table.add_row ['Date(2019, 1, 1)', 0, '6', 1, 3, 3]
    data_table.add_row ['Date(2019, 1, 2)', 0, '8', 1, 4, 3]
    data_table.add_row ['Date(2019, 1, 3)', 0, '9', 3, 3, 3]
    data_table.add_row ['Date(2019, 1, 4)', 0, '10', 4, 4, 2]
    data_table.add_row ['Date(2019, 1, 5)', 0, '10', 5, 4, 1]

    data_table
  end

  def chart_opts
    {
      chartArea: {
        width: '90%',
        height: '80%',
        top: '5%'
      },
      height: 500,
      hAxis: {titleTextStyle: {color: '#333'}},
      vAxis: {minValue: 0, textPosition: 'none'},
      isStacked: true,
      lineWidth: 1,
      areaOpacity: 0.4,
      legend: { position: 'top' },
      series: {
        0 => { color: 'grey' },
        1 => { color: 'blue' },
        2 => { color: 'green' },
        3 => { color: 'red' },
        4 => { color: 'orange' }
      },
      crosshair: { trigger: 'focus', orientation: 'vertical', color: 'grey' },
      focusTarget: 'category',
      annotations: {
        textStyle: {
          color: 'black'
        },
        domain: {
          style: 'line',
          stem: {
            color: 'red',
          }
        },
        datum: {
          style: 'point',
          stem: {
            color: 'black',
            length: '12'
          }
        }
      }
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