class JiraTeamMetrics::IssueTable
  attr_reader :rows

  def initialize(issues)
    @rows = issues
  end

  def column(col_name)
    @rows.map do |issue|
      JiraTeamMetrics::IssueFieldResolver.new(issue).resolve(col_name)
    end
  end

  def value_for(col_name, row_index)
    JiraTeamMetrics::IssueFieldResolver.new(@rows[row_index]).resolve(col_name)
  end
end