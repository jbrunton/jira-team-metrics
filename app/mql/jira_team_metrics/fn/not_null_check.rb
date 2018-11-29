class JiraTeamMetrics::Fn::NotNullCheck
  def call(_, value)
    value.not_null
  end

  def self.register(ctx)
    ctx.register_function(
      'has(JiraTeamMetrics::AST::FieldExpr::ComparisonContext)',
      JiraTeamMetrics::Fn::NotNullCheck.new)
  end
end