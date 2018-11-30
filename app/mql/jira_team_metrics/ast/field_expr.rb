class JiraTeamMetrics::AST::FieldExpr
  def initialize(field_name)
    @field_name = field_name
  end

  def eval(ctx)
    if ctx.expr_type == :rhs
      raise JiraTeamMetrics::ParserError, JiraTeamMetrics::ParserError::FIELD_RHS_ERROR
    end
    JiraTeamMetrics::Eval::ColumnExprRef.new(@field_name, ctx.table)
  end
end