class JiraTeamMetrics::MqlInterpreter
  def eval(query, board, issues)
    Rails.logger.info "Evaluating MQL query: #{query}"

    return issues if query.blank?

    parser = JiraTeamMetrics::MqlStatementParser.new
    transform = MqlTransform.new
    clean_query = query.tr("\n", ' ').strip
    ast = transform.apply(parser.parse(clean_query))

    if ast.class == Hash
      binding.pry
      raise JiraTeamMetrics::ParserError, "Unable to parse expression"
    end

    ctx = build_context(board, issues)

    # if !issues.nil? && ast.class != JiraTeamMetrics::AST::SelectStatement
    #   result = ctx.table.select_rows do |row_index|
    #     ast.eval(ctx.copy(:where, table: ctx.table, row_index: row_index))
    #   end
    # else
      result = ast.eval(ctx)
    # end

    result.class == JiraTeamMetrics::Eval::MqlIssuesTable ? result.rows : result
  end

  private

  def build_context(board, issues)
    table = issues ? JiraTeamMetrics::Eval::MqlIssuesTable.new(issues) : nil
    context = JiraTeamMetrics::EvalContext.new(board, table)

    # aggregation functions
    JiraTeamMetrics::Fn::CountAll.register(context)

    # date functions
    JiraTeamMetrics::Fn::DateToday.register(context)
    JiraTeamMetrics::Fn::DateConstructor.register(context)
    JiraTeamMetrics::Fn::DateParser.register(context)

    # data sources
    JiraTeamMetrics::Fn::DataSource.register(context)

    # misc.
    JiraTeamMetrics::Fn::NotNullCheck.register(context)
    JiraTeamMetrics::Fn::IssueFilter.register(context)
    context
  end

  class MqlTransform < Parslet::Transform
    rule(fun: { ident: simple(:ident), args: subtree(:args) }) do
      JiraTeamMetrics::AST::FuncCallExpr.new(ident.to_s, args)
    end

    rule(int: simple(:int)) do
      value = Integer(int)
      JiraTeamMetrics::AST::ValueExpr.new(value)
    end

    rule(bool: simple(:bool)) do
      value = ActiveModel::Type::Boolean.new.cast(bool.to_s)
      JiraTeamMetrics::AST::ValueExpr.new(value)
    end

    rule(str: simple(:str)) do
      JiraTeamMetrics::AST::ValueExpr.new(str.to_s)
    end

    rule(field: { ident: simple(:ident) }) do
      JiraTeamMetrics::AST::FieldExpr.new(ident.to_s)
    end

    # rule(sort: { expr: subtree(:expr), sort_by: subtree(:sort_by), order: subtree(:order) }) do
    #   JiraTeamMetrics::AST::SortExpr.new(expr, sort_by, order)
    # end

    # rule(stmt: { from: subtree(:from), where: subtree(:where) }) do
    #   JiraTeamMetrics::AST::SelectStatement.new(from, where)
    # end
    #
    # rule(stmt: { from: subtree(:from), where: subtree(:where) }) do
    #   JiraTeamMetrics::AST::SelectStatement.new(from, where)
    # end
    #

    SelectClause = Struct.new(:exprs)
    FromClause = Struct.new(:data_source)
    WhereClause = Struct.new(:expr)
    SortClause = Struct.new(:expr, :order)
    GroupClause = Struct.new(:expr)

    rule(select_clause: { op: '*' }) { SelectClause.new(nil) }
    rule(select_clause: { exprs: subtree(:exprs) }) { SelectClause.new(exprs) }
    rule(from_clause: { data_source: subtree(:data_source) }) { FromClause.new(data_source) }
    #rule(where_clause: nil) { WhereClause.new(nil) }
    rule(where_clause: { expr: subtree(:expr) }) { WhereClause.new(expr) }
    #rule(sort_clause: nil) { SortClause.new(nil, nil) }
    rule(sort_clause: { expr: subtree(:expr), order: subtree(:order) }) { SortClause.new(expr, order) }
    rule(group_clause: { expr: subtree(:expr) }) { GroupClause.new(expr) }

    rule(stmt: {
      select: subtree(:select),
      from: subtree(:from),
      where: subtree(:where),
      sort: subtree(:sort),
      group: subtree(:group)
    }) do
      JiraTeamMetrics::AST::SelectStatement.new(
        select.exprs,
        from.data_source,
        where.try(:expr),
        sort.try(:expr),
        sort.try(:order))
    end

    rule(stmt: { expr: (subtree(:expr)) }) do
      JiraTeamMetrics::AST::ExprStatement.new(expr)
    end

    rule(lhs: subtree(:lhs), op: '+', rhs: subtree(:rhs)) { JiraTeamMetrics::AST::BinOpExpr.new(lhs, :+, rhs) }

    rule(lhs: subtree(:lhs), op: '-', rhs: subtree(:rhs)) { JiraTeamMetrics::AST::BinOpExpr.new(lhs, :-, rhs) }
    rule(lhs: subtree(:lhs), op: '*', rhs: subtree(:rhs)) { JiraTeamMetrics::AST::BinOpExpr.new(lhs, :*, rhs) }
    rule(lhs: subtree(:lhs), op: '/', rhs: subtree(:rhs)) { JiraTeamMetrics::AST::BinOpExpr.new(lhs, :/, rhs) }

    rule(lhs: subtree(:lhs), op: 'and', rhs: subtree(:rhs)) { JiraTeamMetrics::AST::BinOpExpr.new(lhs, :&, rhs) }
    rule(lhs: subtree(:lhs), op: 'or', rhs: subtree(:rhs)) { JiraTeamMetrics::AST::BinOpExpr.new(lhs, :|, rhs) }

    rule(lhs: subtree(:lhs), op: '=', rhs: subtree(:rhs)) { JiraTeamMetrics::AST::BinOpExpr.new(lhs, :==, rhs) }
    rule(lhs: subtree(:lhs), op: '<', rhs: subtree(:rhs)) { JiraTeamMetrics::AST::BinOpExpr.new(lhs, :<, rhs) }
    rule(lhs: subtree(:lhs), op: '>', rhs: subtree(:rhs)) { JiraTeamMetrics::AST::BinOpExpr.new(lhs, :>, rhs) }
    rule(lhs: subtree(:lhs), op: '<=', rhs: subtree(:rhs)) { JiraTeamMetrics::AST::BinOpExpr.new(lhs, :<=, rhs) }
    rule(lhs: subtree(:lhs), op: '>=', rhs: subtree(:rhs)) { JiraTeamMetrics::AST::BinOpExpr.new(lhs, :>=, rhs) }

    rule(lhs: subtree(:lhs), op: 'includes', rhs: subtree(:rhs)) { JiraTeamMetrics::AST::BinOpExpr.new(lhs, :include?, rhs) }

    rule(not: subtree(:rhs)) { JiraTeamMetrics::AST::NotOpExpr.new(rhs) }
  end
end
