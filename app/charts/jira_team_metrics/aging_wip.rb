class JiraTeamMetrics::AgingWip
  def initialize(board, chart_params)
    @board = board
    @params = chart_params
  end

  def json_data
    wip_issues = @board.all_issues.select do |issue|
      issue.status_category == 'In Progress' &&
        issue.started
    end
    if @params.query.blank?
      issues = wip_issues
    else
      issues = JiraTeamMetrics::MqlInterpreter.new(@board, wip_issues).eval(@params.query)
    end
    data_table = JiraTeamMetrics::DataTableBuilder.new
      .data(issues)
      .pick(:key, :summary, :started)
      .build
      .sort_by('started')

    data_table.add_column('now', Array.new(data_table.rows.count, Time.now))

    data_table.to_json
  end
end