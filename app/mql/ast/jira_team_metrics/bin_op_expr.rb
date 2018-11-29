class JiraTeamMetrics::BinOpExpr
  def initialize(lhs, op, rhs)
    @lhs = lhs
    @op = op
    @rhs = rhs
  end

  def eval(ctx)
    lhs_value = @lhs.eval(ctx.copy(expr_type: :lhs))
    rhs_value = @rhs.eval(ctx.copy(expr_type: :rhs))
    if lhs_value.class == JiraTeamMetrics::FieldExpr::ComparisonContext
      lhs_value.eval(@op, rhs_value)
    else
      lhs_value.send(@op, rhs_value)
    end
  end
end
