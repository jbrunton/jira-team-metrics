class JiraTeamMetrics::AST::ValueExpr
  def initialize(value)
    @value = value
  end

  def eval(_)
    @value
  end
end