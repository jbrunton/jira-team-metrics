class JiraTeamMetrics::AgingWip
  def initialize(board, chart_params)
    @board = board
    @params = chart_params
  end

  def data_table
    data_table = JiraTeamMetrics::DataTableBuilder.new
      .data(wip_issues)
      .pick(:key, :summary, :started)
      .build

    data_table.add_column('now', Array.new(data_table.rows.count, Time.now))

    data_table
  end

  def chart_opts
    cycle_times = completed_issues.map{ |issue| issue.cycle_time }
    percentile_50 = cycle_times.percentile(50)
    percentile_70 = cycle_times.percentile(70)
    {
      colors: wip_issues.map do |issue|
        if (Time.now - issue.started) < percentile_50 * 60 * 60 * 24
          '#03a9f4'
        elsif (Time.now - issue.started) < percentile_70 * 60 * 60 * 24
          '#ff9800'
        else
          '#f44336'
        end
      end
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
end