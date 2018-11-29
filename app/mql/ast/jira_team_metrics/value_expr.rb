class JiraTeamMetrics::ValueExpr
  def initialize(value)
    @value = value
  end

  def eval(_)
    @value
  end
end