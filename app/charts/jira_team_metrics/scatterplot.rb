class JiraTeamMetrics::Scatterplot
  def initialize(board, chart_params)
    @board = board
    @params = chart_params
  end

  def json_data
    completed_issues = @board.completed_issues.select do |issue|
      @params.date_range.start_date <= issue.completed &&
        issue.completed < @params.date_range.end_date
    end
    data_table = JiraTeamMetrics::DataTableBuilder.new
      .data(completed_issues)
      .pick(:completed, :cycle_time)
      .build
      .sort_by('completed')

    cycle_times = data_table.column_values('cycle_time')
    percentile_50 = cycle_times.percentile(50)
    percentile_85 = cycle_times.percentile(85)

    data_table
      .add_column('50th percentile')
      .add_column('85th percentile')
      .insert_row(0, [data_table.rows[0][0], nil, percentile_50, percentile_85])
      .add_row([data_table.rows[data_table.rows.count-1][0], nil, percentile_50, percentile_85])

    data_table.to_json
  end

  def chart_options

  end
end