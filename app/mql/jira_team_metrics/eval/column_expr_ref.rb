class JiraTeamMetrics::Eval::ColumnExprRef
  def initialize(field_name, issues)
    @field_name = field_name
    @issues = issues
  end

  def eval(op, rhs_value)
    @issues.select do |issue|
      field = JiraTeamMetrics::IssueFieldResolver.new(issue).resolve(@field_name)
      if !field.nil?
        field.send(op, rhs_value)
      else
        false
      end
    end
  end

  def not_null
    @issues.select do |issue|
      !JiraTeamMetrics::IssueFieldResolver.new(issue).resolve(@field_name).nil?
    end
  end

  def select_field
    @issues.map do |issue|
      JiraTeamMetrics::IssueFieldResolver.new(issue).resolve(@field_name)
    end
  end
end