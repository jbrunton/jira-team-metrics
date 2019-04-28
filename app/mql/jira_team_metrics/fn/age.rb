class JiraTeamMetrics::Fn::Age
  def call(ctx, age_type)
    issue = ctx.table.rows.at(ctx.row_index)
    case
      when age_type == 'since started'
        (ctx.execution_time - issue.started_time).to_i
      when age_type == 'since created'
        (ctx.execution_time - issue.issue_created.to_datetime).to_i
      when age_type == 'in progress'
        date_range = JiraTeamMetrics::DateRange.new(issue.issue_created.to_datetime, [issue.completed_time, ctx.execution_time].compact.first)
        issue.duration_in_range(date_range).to_i
      else
        raise JiraTeamMetrics::ParserError,
          "Unexpected argument for age(): %1s. Expected 'since started', 'since created', 'in progress'" % age_type
    end
  end

  def self.register(ctx)
    ctx.register_function(
      'age(String)',
      JiraTeamMetrics::Fn::Age.new)
  end
end