class JiraTeamMetrics::Fn::CountAll
  def call(ctx)
    ctx.issues.count
  end

  def self.register(ctx)
    ctx.register_function('count()', JiraTeamMetrics::Fn::CountAll.new)
  end
end