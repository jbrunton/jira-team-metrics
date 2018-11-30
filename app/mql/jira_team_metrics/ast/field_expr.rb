class JiraTeamMetrics::AST::FieldExpr
  def initialize(field_name)
    @field_name = field_name
  end

  def eval(ctx)
    if ctx.expr_type == :select
      ctx.table.select_column(@field_name)
    else
      JiraTeamMetrics::Eval::ColumnExprRef.new(@field_name, ctx.table)
    end
  end
end