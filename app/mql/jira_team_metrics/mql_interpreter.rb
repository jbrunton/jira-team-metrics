class JiraTeamMetrics::MqlInterpreter
  def eval(query, board, issues)
    Rails.logger.info "Evaluating MQL query: #{query}"

    return JiraTeamMetrics::Eval::MqlTable.issues_table(issues) if query.blank?

    parser = JiraTeamMetrics::MqlStatementParser.new
    transform = MqlTransform.new
    clean_query = query.tr("\n", ' ').strip
    ast = transform.apply(parser.parse(clean_query))

    if ast.class == Hash
      raise JiraTeamMetrics::ParserError, "Unable to parse expression"
    end

    ctx = JiraTeamMetrics::EvalContext.build(board, issues)

    ast.eval(ctx)
  end

  private

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

    SelectClause = Struct.new(:exprs)
    FromClause = Struct.new(:data_source)
    WhereClause = Struct.new(:expr)
    SortClause = Struct.new(:expr, :order)
    GroupClause = Struct.new(:expr)

    rule(select_clause: { op: '*' }) { SelectClause.new(nil) }
    rule(select_clause: { exprs: subtree(:exprs) }) { SelectClause.new(exprs) }
    rule(from_clause: { data_source: subtree(:data_source) }) { FromClause.new(data_source) }
    rule(where_clause: { expr: subtree(:expr) }) { WhereClause.new(expr) }
    rule(sort_clause: { expr: subtree(:expr), order: subtree(:order) }) { SortClause.new(expr, order) }
    rule(group_clause: { expr: subtree(:expr) }) { GroupClause.new(expr) }

    rule(stmt: {
      select: subtree(:select),
      from: subtree(:from),
      where: subtree(:where),
      sort: subtree(:sort),
      group: subtree(:group)
    }) do
      JiraTeamMetrics::AST::SelectStatement.new({
        select_exprs: select.exprs,
        data_source: from.data_source,
        where_expr: where.try(:expr),
        sort_expr: sort.try(:expr),
        sort_order: sort.try(:order),
        group_expr: group.try(:expr)
      })
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
