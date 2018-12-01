class JiraTeamMetrics::AST::NotOpExpr
  def initialize(rhs)
    @rhs = rhs
  end

  def eval(ctx)
    rhs_value = @rhs.eval(ctx)
    if rhs_value.class == Array
      ctx.table.select{ |issue| !rhs_value.include?(issue) }
    else
      !rhs_value
    end
  end

  def expr_name
    "not #{@rhs.expr_name}"
  end
end