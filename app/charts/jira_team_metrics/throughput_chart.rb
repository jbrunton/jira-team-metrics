class JiraTeamMetrics::ThroughputChart
  include JiraTeamMetrics::FormattingHelper

  def initialize(board, chart_params, project = nil)
    @board = board
    @params = chart_params
    @project = project
  end

  def data_table
    issues = @board.completed_issues(@params.date_range)
    issues = JiraTeamMetrics::TeamScopeReport.issues_for_team(issues, @params.team) if @params.team
    issues = JiraTeamMetrics::MqlInterpreter.new(@board, issues).eval(@params.to_query)

    data_table = JiraTeamMetrics::DataTableBuilder.new
        .data(issues)
        .pick(:completed_time, :key)
        .build
        .select('completed_time').count('key', as: 'Count')
        .group(if_nil: 0, &method(:group_by))
        .sort_by('completed_time')

    data_table.insert_if_missing(@params.date_range.to_a(@params.step_interval), [0], &method(:group_by))

    unless @params.step_interval == 'Monthly'
      th_counts = data_table.column_values('Count')
      th_slice_size = @params.step_interval == 'Daily' ? 14 : 4
      th_averages = th_counts.count.times.map do |index|
        if index >= th_slice_size - 1
          start = index - (th_slice_size - 1)
          length = th_slice_size
          th_counts.slice(start, length).mean * (@params.step_interval == 'Daily' ? 7.0 : 1.0)
        else
          nil
        end
      end
      avg_column_name = 'Rolling Avg / Week ' + (@params.step_interval == 'Daily' ? '(last 14 days)' : '(prev. 4 weeks)')
      data_table.add_column(avg_column_name, th_averages)
    end

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
        legend: {
          position: 'top'
        },
        height: 500,
        series: {
            0 => { lineWidth: 1, pointSize: 4, color: 'indianred' },
            1 => { lineWidth: 2, pointSize: 0, color: 'steelblue' }
        },
        vAxis: {
          minValue: 0
        }
    }
  end

  def group_by(date)
    case @params.step_interval
      when 'Daily'
        date.to_date
      when 'Weekly'
        date.to_date.beginning_of_week
      when 'Monthly'
        date.to_date.beginning_of_month
    end
  end
end