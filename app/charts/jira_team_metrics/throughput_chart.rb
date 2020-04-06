class JiraTeamMetrics::ThroughputChart
  include JiraTeamMetrics::FormattingHelper

  def initialize(board, report_params, project = nil)
    @board = board
    @params = report_params
    @project = project
  end

  def data_table
    issues = @board.completed_issues(@params.date_range)
    issues = JiraTeamMetrics::TeamScopeReport.issues_for_team(issues, @params.team) if @params.team
    issues = JiraTeamMetrics::MqlInterpreter.new.eval(@params.to_query, @board, issues).rows

    data_table = JiraTeamMetrics::DataTableBuilder.new
        .data(issues)
        .pick(:completed_time, :key)
        .build
        .select('completed_time').count('key', as: 'Count')
        .group(if_nil: 0, &method(:group_by))
        .sort_by('completed_time')
        .insert_if_missing(@params.date_range.to_a(@params.step_interval), [0], &method(:group_by))

    data_table.add_percentiles('Count', [25, 50, 75]) if issues.count >= 5

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
            '1' => series_opts('#f44336', true),
            '2' => series_opts('#ff9800', true),
            '3' => series_opts('#03a9f4', true)
        },
        vAxis: {
          minValue: 0
        }
    }
  end

  def group_by(date)
    JiraTeamMetrics::ThroughputChart.group_by(date, @params.step_interval)
  end

  def self.group_by(date, step_interval)
    case step_interval
      when 'Daily'
        date.to_date
      when 'Weekly'
        date.to_date.beginning_of_week
      when 'Monthly'
        date.to_date.beginning_of_month
    end
  end

private
  def add_rolling_averages(data_table)
    counts = data_table.column_values('Count')
    slice_size = avg_sample_size
    averages = counts.count.times.map do |index|
      if index >= slice_size - 1
        start = index - (slice_size - 1)
        length = slice_size
        counts.slice(start, length).mean * avg_scale_factor
      else
        nil
      end
    end
    data_table.add_column(avg_column_name, averages)
  end

  def avg_sample_size
    case @params.step_interval
      when 'Daily'
        14 # i.e. prev 2 weeks
      when 'Weekly'
        4 # i.e. prev 4 weeks
    end
  end

  def avg_scale_factor
    case @params.step_interval
      when 'Daily'
        7.0 # i.e. scale to a weekly figure
      when 'Weekly'
        1.0 # i.e. keep it at weekly
    end
  end

  def avg_column_name
    case @params.step_interval
      when 'Daily'
        'Rolling Avg / Week (prev 14 days)'
      when 'Weekly'
        'Rolling Avg / Week (prev 4 weeks)'
    end
  end

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