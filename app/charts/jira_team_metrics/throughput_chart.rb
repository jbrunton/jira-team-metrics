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
        .select('completed_time').count('key', as: 'Count')
        .group(if_nil: 0) { |completed_time| completed_time.to_date }
        .sort_by('completed_time')
        .insert_if_missing(@params.date_range.to_a, [0])

    th_counts = data_table.column_values('Count')
    th_averages = th_counts.count.times.map do |index|
      if index >= 13
        start = index - 13
        length = 14
        th_counts.slice(start, length).mean
      else
        nil
      end
    end
    data_table.add_column('Average', th_averages)
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
        legend: {
            position: 'none'
        },
        chartArea: {
            width: '90%',
            height: '80%',
            top: '5%'
        },
        height: 500,
        series: {
            0 => { pointSize: 4, color: 'indianred' },
            1 => { lineWidth: 2, pointSize: 0, color: 'indianred' }
        }
    }
  end
end