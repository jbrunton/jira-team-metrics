class JiraTeamMetrics::AST::ExprStatement
  def initialize(expr, sort_expr, sort_order)
    @expr = expr
    @sort_expr = sort_expr
    @sort_order = sort_order
  end

  def eval(ctx)
    if ctx.table.nil?
      # treat as a simple expression
      @expr.eval(ctx)
    else
      # treat as an expression to filter the table
      @results = ctx.table
      eval_expr(ctx)
      apply_sort_clause(ctx)
      @results
    end
  end

  private

  def eval_expr(ctx)
    @results = @results.select_rows do |row_index|
      @expr.eval(ctx.copy(@results, row_index))
    end
  end

  def apply_sort_clause(ctx)
    unless @sort_expr.nil?
      @results = @results.sort_rows(@sort_order) do |row_index|
        @sort_expr.eval(ctx.copy(@results, row_index))
      end
    end
  end
end