class JiraTeamMetrics::AgingWipChart
  def initialize(board, chart_params)
    @board = board
    @params = chart_params
  end

  def data_table
    data_table = JiraTeamMetrics::DataTableBuilder.new
      .data(wip_issues)
      .pick(:key, :summary, :started)
      .build

    now = Time.now

    data_table.add_column('now', Array.new(data_table.rows.count, now))
    data_table.insert_row(0, ['Percentiles', '85th', now - percentiles[85].days, now])
    data_table.insert_row(1, ['Percentiles', '70th', now - percentiles[70].days, now])
    data_table.insert_row(2, ['Percentiles', '50th', now - percentiles[50].days, now])

    data_table
  end

  def chart_opts
    {
      colors: ['#f44336', '#ff9800', '#03a9f4'] + wip_issues.map do |issue|
        if (Time.now - issue.started) < percentiles[50] * 60 * 60 * 24
          '#03a9f4'
        elsif (Time.now - issue.started) < percentiles[70] * 60 * 60 * 24
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
      data: data_table.to_json('started' => { type: 'datetime' }, 'now' => { type: 'datetime' })
    }
  end

private
  def wip_issues
    @wip_issues ||= begin
      issues = @board.all_issues.select do |issue|
        issue.status_category == 'In Progress' &&
          issue.started
      end
      if @params.query.blank?
        issues
      else
        JiraTeamMetrics::MqlInterpreter.new(@board, issues).eval(@params.query)
      end
    end.sort_by { |issue| issue.started }
  end

  def completed_issues
    @completed_issues ||= @board.completed_issues.select do |issue|
      @params.date_range.start_date <= issue.completed &&
        issue.completed < @params.date_range.end_date
    end.sort_by { |issue| issue.cycle_time }
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