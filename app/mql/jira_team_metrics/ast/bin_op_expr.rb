class JiraTeamMetrics::AST::BinOpExpr
  def initialize(lhs, op, rhs)
    @lhs = lhs
    @op = op
    @rhs = rhs
  end

  def eval(ctx)
    lhs_value = @lhs.eval(ctx)
    rhs_value = @rhs.eval(ctx)

    if lhs_value.class == JiraTeamMetrics::Eval::ColumnExprRef

    else


    rhs_value = @rhs.eval(ctx)
    if lhs_value.class == JiraTeamMetrics::Eval::ColumnExprRef
      lhs_value.eval(@op, rhs_value)
    else
      if [lhs_value.class, rhs_value.class].include?(Array) && rhs_value.class != lhs_value.class
        raise JiraTeamMetrics::ParserError, "Mismatched expression types for bin op: #{lhs_value.class}, #{rhs_value.class}"
      end
      lhs_value.send(@op, rhs_value)
    end
  end
end
