class JiraTeamMetrics::NotOpExpr
  def initialize(rhs)
    @rhs = rhs
  end

  def eval(ctx)
    rhs_value = @rhs.eval(ctx.copy(:none))
    if rhs_value.class == Array
      ctx.issues.select{ |issue| !rhs_value.include?(issue) }
    else
      !rhs_value
    end
  end
end