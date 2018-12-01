class JiraTeamMetrics::AST::SelectStatement
  def initialize(select_exprs, data_source, where_expr, sort_expr, sort_order)
    @select_exprs = select_exprs
    @data_source = data_source
    @where_expr = where_expr
    @sort_expr = sort_expr
    @sort_order = sort_order
  end

  def eval(ctx)
    from_table = @data_source.eval(ctx)
    if @where_expr.nil?
      filtered_table = from_table
    else
      filtered_table = from_table.select_rows do |row_index|
        @where_expr.eval(ctx.copy(:where, table: from_table, row_index: row_index))
      end
    end
    if @select_exprs.nil?
      filtered_table
    else
      filtered_table.select_rows.map do |row_index|
        @select_exprs.map do |select_expr|
          select_expr.eval(ctx.copy(:select, table: filtered_table, row_index: row_index))
        end
      end
    end
    filtered_table
  end
end