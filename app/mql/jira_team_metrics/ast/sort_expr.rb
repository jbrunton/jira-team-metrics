class JiraTeamMetrics::AST::SortExpr
  def initialize(expr, sort_by, order)
    @expr = expr
    @sort_by = sort_by
    @order = order
  end

  def eval(ctx)
    expr_value = @expr.eval(ctx.copy(:none))

    sorted_issues = expr_value.sort_by { |issue| sort_key_for(issue, ctx) }
    if @order == 'desc'
      sorted_issues.reverse
    else
      sorted_issues
    end
  end

  def field_name(ctx)
    @field_name ||= if @sort_by.class == JiraTeamMetrics::AST::ValueExpr
      @sort_by.eval(ctx.copy(:none))
    else
      (@sort_by[:identifier] || @sort_by[:value]).to_s
    end
  end

  def sort_key_for(issue, ctx)
    value = JiraTeamMetrics::IssueFieldResolver.new(issue).resolve(field_name(ctx))
    if value.nil? then
      [0, nil]
    else
      [1, value]
    end
  end
end
