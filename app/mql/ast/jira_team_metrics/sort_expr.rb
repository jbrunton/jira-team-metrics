class JiraTeamMetrics::SortExpr
  def initialize(expr, sort_by, order)
    @expr = expr
    @sort_by = sort_by
    @order = order
  end

  def eval(ctx)
    expr_value = @expr.eval(ctx.copy())

    sorted_issues = expr_value.sort_by { |issue| sort_key_for(issue) }
    if @order == 'desc'
      sorted_issues.reverse
    else
      sorted_issues
    end
  end

  def field_name
    @field_name ||= (@sort_by[:identifier] || @sort_by[:value]).to_s
  end

  def sort_key_for(issue)
    value = JiraTeamMetrics::IssueFieldResolver.new(issue).resolve(field_name)
    if value.nil? then
      [0, nil]
    else
      [1, value]
    end
  end
end
