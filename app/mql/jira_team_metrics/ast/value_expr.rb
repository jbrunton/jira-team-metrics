class JiraTeamMetrics::AST::ValueExpr
  attr_reader :value

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