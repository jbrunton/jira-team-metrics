class JiraTeamMetrics::NotNullCheck
  def call(_, value)
    value.not_null
  end

  def self.register(ctx)
    ctx.register_function(
      'has(JiraTeamMetrics::FieldExpr::ComparisonContext)',
      JiraTeamMetrics::NotNullCheck.new)
  end
end