class JiraTeamMetrics::AST::BinOpExpr
  def initialize(lhs, op, rhs)
    @lhs = lhs
    @op = op
    @rhs = rhs
  end

  def eval(ctx)
    lhs_value = @lhs.eval(ctx)
    rhs_value = @rhs.eval(ctx)
    lhs_value.send(@op, rhs_value)
  end

  def expr_name
    "#{@lhs.expr_name} #{@op} #{@rhs.expr_name}"
  end
end
