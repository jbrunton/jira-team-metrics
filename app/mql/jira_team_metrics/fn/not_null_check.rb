class JiraTeamMetrics::Fn::NotNullCheck
  def call(_, value)
    !value.nil?
  end

  def self.register(ctx)
    ctx.register_function(
      'has(Object)',
      JiraTeamMetrics::Fn::NotNullCheck.new)
  end
end