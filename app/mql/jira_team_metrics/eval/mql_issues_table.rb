class JiraTeamMetrics::Eval::MqlIssuesTable < JiraTeamMetrics::Eval::MqlTable
  def initialize(issues)
    @rows = issues
    @columns = ['key', 'summary', 'issuetype']
  end

  def select_column(col_name)
    col_values = rows.map do |issue|
      [JiraTeamMetrics::IssueFieldResolver.new(issue).resolve(col_name)]
    end
    JiraTeamMetrics::Eval::MqlTable.new(
      [col_name],
      col_values
    )
  end

  def select_field(col_name, row_index)
    JiraTeamMetrics::IssueFieldResolver.new(rows[row_index]).resolve(col_name)
  end
end