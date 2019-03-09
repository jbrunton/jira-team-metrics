class JiraTeamMetrics::ScatterplotChart
  include JiraTeamMetrics::FormattingHelper

  def initialize(board, report_params)
    @board = board
    @params = report_params
  end

  def data_table
    completed_issues = @board.completed_issues(@params.date_range)
    filtered_issues = JiraTeamMetrics::MqlInterpreter.new.eval(@params.to_query, @board, completed_issues).rows
    data_table = JiraTeamMetrics::DataTableBuilder.new
      .data(filtered_issues)
      .pick(:completed_time, :cycle_time, :key)
      .build
      .sort_by('completed_time')
      .add_percentiles('cycle_time', [50, 70, 85, 95])

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
        '1' => series_opts('#f44336', false),
        '2' => series_opts('#f44336', true),
        '3' => series_opts('#ff9800', true),
        '4' => series_opts('#03a9f4', true),
      },
      legend: {
        position: 'none'
      },
      chartArea: {
        width: '90%',
        height: '80%',
        top: '5%'
      },
      height: 500
    }
  end

private
  def series_opts(color, dash)
    opts = {
      type: 'steppedArea',
      color: color,
      areaOpacity: 0
    }
    opts.merge!(lineDashStyle: [4, 4]) if dash
    opts
  end
end