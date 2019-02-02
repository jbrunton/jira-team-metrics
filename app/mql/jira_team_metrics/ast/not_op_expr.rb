class JiraTeamMetrics::AST::NotOpExpr
  attr_reader :expr

  def initialize(expr)
    @expr = expr
  end

  def eval(ctx)
    rhs_value = @expr.eval(ctx)
    if rhs_value.class == Array
      ctx.table.select{ |issue| !rhs_value.include?(issue) }
    else
      !rhs_value
    end
  end

  def expr_name
    if @expr.class == JiraTeamMetrics::AST::ValueExpr
      "not #{@expr.expr_name}"
    else
      "not (#{@expr.expr_name})"
    end
  end
end