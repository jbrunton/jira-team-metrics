class JiraTeamMetrics::Fn::Age
  def call(ctx, age_type)
    issue = ctx.table.rows.at(ctx.row_index)
    issue.age(age_type, ctx.execution_time)
  end

  def self.register(ctx)
    ctx.register_function(
      'age(String)',
      JiraTeamMetrics::Fn::Age.new)
  end
end