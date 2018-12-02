class JiraTeamMetrics::AST::ExprStatement
  def initialize(expr)
    @expr = expr
  end

  def eval(ctx)
    if ctx.table.nil?
      # treat as a simple expression
      @expr.eval(ctx)
    else
      # treat as an expression to filter the table
      ctx.table.select_rows do |row_index|
        @expr.eval(ctx.copy(ctx.table, row_index))
      end
    end
  end
end