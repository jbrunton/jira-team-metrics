class JiraTeamMetrics::AST::FieldExpr
  def initialize(field_name)
    @field_name = field_name
  end

  def eval(ctx)
    ctx.table.select_field(@field_name, ctx.row_index)
  end

  def expr_name
    @field_name
  end
end