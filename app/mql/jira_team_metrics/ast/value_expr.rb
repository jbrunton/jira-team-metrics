class JiraTeamMetrics::AST::ValueExpr
  def initialize(value)
    @value = value
  end

  def eval(_)
    @value
  end

  def expr_name
    @value.to_s
  end
end