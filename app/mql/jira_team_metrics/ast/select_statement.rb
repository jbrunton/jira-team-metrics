class JiraTeamMetrics::AST::SelectStatement
  def initialize(data_source, where_expr, select_exprs = nil)
    @data_source = data_source
    @where_expr = where_expr
    @select_exprs = select_exprs
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
      filtered_table.rows.each_with_index.map do |_, row_index|
        @select_exprs.map do |select_expr|
          select_expr.eval(ctx.copy(:select, table: filtered_table, row_index: row_index))
        end
      end
    end
  end
end