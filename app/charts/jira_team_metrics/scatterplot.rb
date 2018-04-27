class JiraTeamMetrics::Scatterplot
  include JiraTeamMetrics::FormattingHelper

  def initialize(board, chart_params)
    @board = board
    @params = chart_params
  end

  def data_table
    completed_issues = @board.completed_issues.select do |issue|
      @params.date_range.start_date <= issue.completed &&
        issue.completed < @params.date_range.end_date
    end
    data_table = JiraTeamMetrics::DataTableBuilder.new
      .data(completed_issues)
      .pick(:completed, :cycle_time, :key)
      .build
      .sort_by('completed')

    cycle_times = data_table.column_values('cycle_time')
    percentile_50 = cycle_times.percentile(50)
    percentile_85 = cycle_times.percentile(85)

    data_table
      .add_column("85th percentile")
      .add_column("50th percentile")
      .add_row([data_table.rows[0][0], nil, nil, percentile_85, percentile_50])
      .add_row([data_table.rows[data_table.rows.count-1][0], nil, nil, percentile_85, percentile_50])

    data_table
  end

  def json_data
    {
      chartOpts: chart_opts,
      data: data_table.to_json('key' => { role: 'annotationText' })
    }
  end

  def chart_opts
    {
      seriesType: 'scatter',
      interpolateNulls: true,
      series: {
          '2' => {
          type: 'steppedArea',
          color: '#FA0',
          areaOpacity: 0
        },
          '1' => {
          type: 'steppedArea',
          color: '#F66',
          areaOpacity: 0
        }
      },
      legend: {
        position: 'none'
      },
      chartArea: {
        width: '90%'
      }
    }
  end
end