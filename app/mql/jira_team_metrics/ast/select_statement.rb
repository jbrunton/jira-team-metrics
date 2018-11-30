class JiraTeamMetrics::AST::SelectStatement
  def initialize(data_source, where_expr, select_exprs = nil)
    @data_source = data_source
    @where_expr = where_expr
    @select_exprs = select_exprs
  end

  def eval(ctx)
    from_issues = @data_source.eval(ctx)
    if @where_expr.nil?
      where_issues = from_issues
    else
      where_issues = @where_expr.eval(ctx.copy(:none, issues: from_issues))
    end
    if @select_exprs.nil?
      where_issues
    else
      columns = @select_exprs.map do |select_expr|
        col_result = select_expr.eval(ctx.copy(:none, issues: where_issues))
        if col_result.class == JiraTeamMetrics::AST::FieldExpr::ComparisonContext
          col_result.select_field
        else
          col_result
        end
      end
      if columns.first.class == Array
        columns.transpose
      else
        columns
      end
    end
  end
end