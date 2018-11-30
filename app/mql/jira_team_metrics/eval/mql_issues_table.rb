class JiraTeamMetrics::Eval::MqlIssuesTable < JiraTeamMetrics::Eval::MqlTable
  def initialize(issues)
    super(['key', 'summary', 'issuetype'], issues)
  end

  def select_field(col_name, row_index)
    JiraTeamMetrics::IssueFieldResolver.new(rows[row_index]).resolve(col_name)
  end

  def select_rows
    selected_rows = []
    @rows.each_with_index do |row, row_index|
      selected_rows << row if yield(row_index)
    end
    JiraTeamMetrics::Eval::MqlIssuesTable.new(selected_rows)
  end
end