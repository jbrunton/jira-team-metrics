class JiraTeamMetrics::DateToday
  def call(_)
    DateTime.now.to_date
  end

  def self.register(ctx)
    ctx.register_function('today()', JiraTeamMetrics::DateToday.new)
  end
end