class JiraTeamMetrics::Fn::NotNullCheck
  def call(_, value)
    value.not_null
  end

  def self.register(ctx)
    ctx.register_function(
      'has(JiraTeamMetrics::Eval::ColumnExprRef)',
      JiraTeamMetrics::Fn::NotNullCheck.new)
  end
end