class JiraTeamMetrics::ThroughputChart
  include JiraTeamMetrics::FormattingHelper

  def initialize(board, chart_params, increment = nil)
    @board = board
    @params = chart_params
    @increment = increment
  end

  def data_table
    issues = @board.completed_issues(@params.date_range)
#    issues = issues.select{ |issue| issue.increment == @increment } unless @increment.nil?
    issues = JiraTeamMetrics::TeamScopeReport.issues_for_team(issues, @params.team) if @params.team
    issues = JiraTeamMetrics::MqlInterpreter.new(@board, issues).eval(@params.query)

    data_table = JiraTeamMetrics::DataTableBuilder.new
        .data(issues)
        .pick(:completed_time, :key)
        .build
        .select('completed_time').count('key', as: 'Count')
        .group(if_nil: 0) { |completed_time| completed_time.to_date }
        .sort_by('completed_time')

    data_table.insert_if_missing(@params.date_range.to_a, [0]) { |date| date.to_date }

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
    data_table.add_column('Avg / Week', th_averages.map{ |x| x.try(:*, 7.0) })
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
        chartArea: {
            width: '90%',
            height: '80%',
            top: '5%'
        },
        height: 500,
        series: {
            0 => { lineWidth: 1, pointSize: 4, color: 'indianred' },
            1 => { lineWidth: 2, pointSize: 0, color: 'steelblue', targetAxisIndex: 1 }
        }
    }
  end
end