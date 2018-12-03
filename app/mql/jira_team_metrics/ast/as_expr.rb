class JiraTeamMetrics::AST::AsExpr
  def initialize(expr, name)
    @expr = expr
    @name = name
  end

  def eval(ctx)
    @expr.eval(ctx)
  end

  def expr_name
    @name
  end
end