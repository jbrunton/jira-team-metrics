class JiraTeamMetrics::Fn::CountAll
  def call(ctx)
    ctx.table.rows[ctx.row_index].last.count
  end

  def self.register(ctx)
    ctx.register_function('count()', JiraTeamMetrics::Fn::CountAll.new)
  end
end