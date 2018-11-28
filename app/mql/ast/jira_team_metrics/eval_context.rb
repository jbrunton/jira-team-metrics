class JiraTeamMetrics::EvalContext
  attr_reader :issues
  attr_reader :expr_type

  def initialize(issues, expr_type = :none)
    @issues = issues
    @expr_type = expr_type
  end

  def copy(opts = {})
    JiraTeamMetrics::EvalContext.new(
      opts[:issues] || issues,
      opts[:expr_type] || expr_type
    )
  end
end