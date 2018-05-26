class JiraTeamMetrics::ThroughputChart
  include JiraTeamMetrics::FormattingHelper

  def initialize(board, chart_params)
    @board = board
    @params = chart_params
  end

  def data_table
    completed_issues = @board.completed_issues(@params.date_range)
    filtered_issues = JiraTeamMetrics::MqlInterpreter.new(@board, completed_issues).eval(@params.query)
    data_table = JiraTeamMetrics::DataTableBuilder.new
        .data(filtered_issues)
        .pick(:completed_time, :key)
        .build

    data_table
        .select('completed_time').count('key', as: 'Count')
        .group(if_nil: 0) { |completed_time| completed_time.to_date }
        .sort_by('completed_time')
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
end