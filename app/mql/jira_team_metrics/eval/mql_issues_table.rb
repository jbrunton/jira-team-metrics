class JiraTeamMetrics::Eval::MqlIssuesTable < JiraTeamMetrics::Eval::MqlTable
  def initialize(issues)
    super(['key', 'summary', 'issuetype'], issues)
  end

  def select_field(col_name, row_index)
    JiraTeamMetrics::IssueFieldResolver.new(rows[row_index]).resolve(col_name)
  end
end