class JiraTeamMetrics::MqlInterpreter
  def eval(query, board, issues)
    Rails.logger.info "Evaluating MQL query: #{query}"

    parser = JiraTeamMetrics::MqlStatementParser.new
    transform = MqlTransform.new
    clean_query = query.gsub("\n", ' ').strip
    ast = transform.apply(parser.parse(clean_query))

    if ast.class == Hash
      raise JiraTeamMetrics::ParserError, "Unable to parse expression"
    end

    ast.eval(JiraTeamMetrics::EvalContext.new(board, issues))
  end

  class MqlTransform < Parslet::Transform
    rule(fun: { ident: simple(:ident), args: subtree(:args) }) { JiraTeamMetrics::FuncCallExpr.new(ident.to_s, args) }

    rule(int: simple(:int)) do
      value = Integer(int)
      JiraTeamMetrics::ValueExpr.new(value)
    end
    rule(bool: simple(:bool)) do
      value = ActiveModel::Type::Boolean.new.cast(bool.to_s)
      JiraTeamMetrics::ValueExpr.new(value)
    end
    rule(str: simple(:str)) { JiraTeamMetrics::ValueExpr.new(str.to_s) }

    rule(field: { ident: simple(:ident) }) do
      JiraTeamMetrics::FieldExpr.new(ident.to_s)
    end

    rule(sort: { expr: subtree(:expr), sort_by: subtree(:sort_by), order: subtree(:order) }) do
      JiraTeamMetrics::SortExpr.new(expr, sort_by, order)
    end

    rule(lhs: subtree(:lhs), op: '+', rhs: subtree(:rhs)) { JiraTeamMetrics::BinOpExpr.new(lhs, :+, rhs) }
    rule(lhs: subtree(:lhs), op: '-', rhs: subtree(:rhs)) { JiraTeamMetrics::BinOpExpr.new(lhs, :-, rhs) }
    rule(lhs: subtree(:lhs), op: '*', rhs: subtree(:rhs)) { JiraTeamMetrics::BinOpExpr.new(lhs, :*, rhs) }
    rule(lhs: subtree(:lhs), op: '/', rhs: subtree(:rhs)) { JiraTeamMetrics::BinOpExpr.new(lhs, :/, rhs) }

    rule(lhs: subtree(:lhs), op: 'and', rhs: subtree(:rhs)) { JiraTeamMetrics::BinOpExpr.new(lhs, :&, rhs) }
    rule(lhs: subtree(:lhs), op: 'or', rhs: subtree(:rhs)) { JiraTeamMetrics::BinOpExpr.new(lhs, :|, rhs) }

    rule(lhs: subtree(:lhs), op: '=', rhs: subtree(:rhs)) { JiraTeamMetrics::BinOpExpr.new(lhs, :==, rhs) }
    rule(lhs: subtree(:lhs), op: '<', rhs: subtree(:rhs)) { JiraTeamMetrics::BinOpExpr.new(lhs, :<, rhs) }
    rule(lhs: subtree(:lhs), op: '>', rhs: subtree(:rhs)) { JiraTeamMetrics::BinOpExpr.new(lhs, :>, rhs) }
    rule(lhs: subtree(:lhs), op: '<=', rhs: subtree(:rhs)) { JiraTeamMetrics::BinOpExpr.new(lhs, :<=, rhs) }
    rule(lhs: subtree(:lhs), op: '>=', rhs: subtree(:rhs)) { JiraTeamMetrics::BinOpExpr.new(lhs, :>=, rhs) }

    rule(lhs: subtree(:lhs), op: 'includes', rhs: subtree(:rhs)) { JiraTeamMetrics::BinOpExpr.new(lhs, :include?, rhs) }

    rule(not: subtree(:rhs)) { JiraTeamMetrics::NotOpExpr.new(rhs) }
  end
end
