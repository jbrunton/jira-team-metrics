class JiraTeamMetrics::Fn::DateConstructor
  def call(_, year, month, day)
    DateTime.new(year, month, day)
  end

  def self.register(ctx)
    ctx.register_function(
      'date(Object, Object, Object)',
      JiraTeamMetrics::Fn::DateConstructor.new)
  end
end