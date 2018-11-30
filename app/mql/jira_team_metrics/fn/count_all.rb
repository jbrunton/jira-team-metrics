class JiraTeamMetrics::Fn::CountAll
  def call(ctx)
    ctx.table.rows.count
  end

  def self.register(ctx)
    ctx.register_function('count()', JiraTeamMetrics::Fn::CountAll.new)
  end
end