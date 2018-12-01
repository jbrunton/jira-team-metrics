class JiraTeamMetrics::AST::SelectStatement
  def initialize(select_exprs, data_source, where_expr, sort_expr, sort_order, group_expr)
    @select_exprs = select_exprs
    @data_source = data_source
    @where_expr = where_expr
    @sort_expr = sort_expr
    @sort_order = sort_order
    @group_expr = group_expr
  end

  def eval(ctx)
    @results = @data_source.eval(ctx)
    apply_where_clause(ctx)
    apply_sort_clause(ctx)
    apply_group_clause(ctx)
    apply_select_clause(ctx)
    @results
  end

  private

  def apply_where_clause(ctx)
    unless @where_expr.nil?
      @results = @results.select_rows do |row_index|
        @where_expr.eval(ctx.copy(:where, table: @results, row_index: row_index))
      end
    end
  end

  def apply_select_clause(ctx)
    unless @select_exprs.nil?
      @results = @results.map_rows do |row_index|
        @select_exprs.map do |select_expr|
          select_expr.eval(ctx.copy(:select, table: @results, row_index: row_index))
        end
      end
    end
  end

  def apply_sort_clause(ctx)
    unless @sort_expr.nil?
      @results = @results.sort_rows(@sort_order) do |row_index|
        @sort_expr.eval(ctx.copy(:sort, table: @results, row_index: row_index))
      end
    end
  end

  def apply_group_clause(ctx)
    unless @group_expr.nil?
      @results = @results.group_by('group') do |row_index|
        @group_expr.eval(ctx.copy(:group, table: @results, row_index: row_index))
      end
    end
  end
end