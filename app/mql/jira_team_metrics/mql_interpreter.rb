class JiraTeamMetrics::MqlInterpreter
  def eval(query, board, issues)
    Rails.logger.info "Evaluating MQL query: #{query}"

    return issues if query.blank?

    parser = JiraTeamMetrics::MqlStatementParser.new
    transform = MqlTransform.new
    clean_query = query.tr("\n", ' ').strip
    ast = transform.apply(parser.parse(clean_query))

    if ast.class == Hash
      raise JiraTeamMetrics::ParserError, "Unable to parse expression"
    end

    ctx = build_context(board, issues)

    result = ast.eval(ctx)
    result.class == JiraTeamMetrics::Eval::MqlIssuesTable ? result.rows : result
  end

  private

  def build_context(board, issues)
    context = JiraTeamMetrics::EvalContext.new(board, JiraTeamMetrics::Eval::MqlIssuesTable.new(issues))

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
    rule(fun: { ident: simple(:ident), args: subtree(:args) }) { JiraTeamMetrics::AST::FuncCallExpr.new(ident.to_s, args) }

    rule(int: simple(:int)) do
      value = Integer(int)
      JiraTeamMetrics::AST::ValueExpr.new(value)
    end
    rule(bool: simple(:bool)) do
      value = ActiveModel::Type::Boolean.new.cast(bool.to_s)
      JiraTeamMetrics::AST::ValueExpr.new(value)
    end
    rule(str: simple(:str)) { JiraTeamMetrics::AST::ValueExpr.new(str.to_s) }

    rule(field: { ident: simple(:ident) }) do
      JiraTeamMetrics::AST::FieldExpr.new(ident.to_s)
    end

    rule(sort: { expr: subtree(:expr), sort_by: subtree(:sort_by), order: subtree(:order) }) do
      JiraTeamMetrics::AST::SortExpr.new(expr, sort_by, order)
    end

    rule(stmt: { from: subtree(:from), where: subtree(:where) }) do
      JiraTeamMetrics::AST::SelectStatement.new(from, where)
    end

    rule(stmt: { select_exprs: subtree(:select_exprs), from: subtree(:from), where: subtree(:where) }) do
      JiraTeamMetrics::AST::SelectStatement.new(from, where, select_exprs)
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
