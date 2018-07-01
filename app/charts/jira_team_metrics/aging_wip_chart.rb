class JiraTeamMetrics::AgingWipChart
  def initialize(board, chart_params)
    @board = board
    @params = chart_params
  end

  def data_table
    data_table = JiraTeamMetrics::DataTableBuilder.new
      .data(wip_issues)
      .pick(:key, :summary, :started_time)
      .build

    now = DateTime.now

    data_table.add_column('now', Array.new(data_table.rows.count, now))
    data_table.insert_row(0, ['Percentiles', '85th', now - percentiles[85], now])
    data_table.insert_row(1, ['Percentiles', '70th', now - percentiles[70], now])
    data_table.insert_row(2, ['Percentiles', '50th', now - percentiles[50], now])

    data_table
  end

  def chart_opts
    {
      colors: ['#f44336', '#ff9800', '#03a9f4'] + wip_issues.map do |issue|
        if (DateTime.now - issue.started_time) < percentiles[50]
          '#03a9f4'
        elsif (DateTime.now - issue.started_time) < percentiles[70]
          '#ff9800'
        else
          '#f44336'
        end
      end,
      height: (wip_issues.count + 3) * 41 + 50
    }
  end

  def json_data
    {
      chartOpts: chart_opts,
      data: data_table.to_json('started_time' => { type: 'datetime' }, 'now' => { type: 'datetime' })
    }
  end

private
  def wip_issues
    JiraTeamMetrics::MqlInterpreter.new(@board, @board.wip_issues.select{ |issue| issue.is_scope? })
        .eval(@params.query)
        .sort_by { |issue| issue.started_time }
  end

  def completed_issues
    JiraTeamMetrics::MqlInterpreter.new(@board, @board.completed_issues(@params.date_range).select{ |issue| issue.is_scope? })
        .eval(@params.query)
        .sort_by { |issue| issue.cycle_time }
  end

  def percentiles
    @percentiles ||= begin
      cycle_times = completed_issues.map{ |issue| issue.cycle_time }
      {
        50 => cycle_times.percentile(50),
        70 => cycle_times.percentile(70),
        85 => cycle_times.percentile(85)
      }
    end
  end
end