class JiraTeamMetrics::ValueExpr
  def initialize(value)
    @value = value
  end

  def eval(ctx)
    @value
  end
end