class JiraTeamMetrics::Fn::DateNow
  def call(_)
    DateTime.now.to_datetime
  end

  def self.register(ctx)
    ctx.register_function('now()', JiraTeamMetrics::Fn::DateNow.new)
  end
end
