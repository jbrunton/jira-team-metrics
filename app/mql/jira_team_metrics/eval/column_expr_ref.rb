class JiraTeamMetrics::Eval::ColumnExprRef
  attr_reader :table
  attr_reader :field_name

  def initialize(field_name, table)
    @field_name = field_name
    @table = table
  end

  def eval(op, rhs_value)
    @table.select_where(field_name) do |field_value|
      if !field_value.nil?
        field_value.send(op, rhs_value)
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