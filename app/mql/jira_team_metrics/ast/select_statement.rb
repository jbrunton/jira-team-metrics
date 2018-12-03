class JiraTeamMetrics::AST::SelectStatement
  def initialize(opts)
    @select_exprs = opts[:select_exprs]
    @data_source = opts[:data_source]
    @where_expr = opts[:where_expr]
    @sort_expr = opts[:sort_expr]
    @sort_order = opts[:sort_order]
    @group_expr = opts[:group_expr]
  end

  def eval(ctx)
    @results = @data_source.eval(ctx)
    apply_where_clause(ctx)
    apply_group_clause(ctx)
    apply_select_clause(ctx)
    apply_sort_clause(ctx)
    @results
  end

  private

  def apply_where_clause(ctx)
    unless @where_expr.nil?
      @results = @results.select_rows do |row_index|
        @where_expr.eval(ctx.copy(@results, row_index))
      end
    end
  end

  def apply_select_clause(ctx)
    unless @select_exprs.nil?
      col_names = @select_exprs.map{ |expr| expr.expr_name }
      @results = @results.map_rows(col_names) do |row_index|
        @select_exprs.map do |select_expr|
          select_expr.eval(ctx.copy(@results, row_index))
        end
      end
    end
  end

  def apply_sort_clause(ctx)
    unless @sort_expr.nil?
      @results = @results.sort_rows(@sort_order) do |row_index|
        @sort_expr.eval(ctx.copy(@results, row_index))
      end
    end
  end

  def apply_group_clause(ctx)
    unless @group_expr.nil?
      @results = @results.group_by(@group_expr.expr_name) do |row_index|
        @group_expr.eval(ctx.copy(@results, row_index))
      end
    end
  end
end