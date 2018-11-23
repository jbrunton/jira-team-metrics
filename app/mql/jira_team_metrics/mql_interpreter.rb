class JiraTeamMetrics::MqlInterpreter
  def eval(query, issues)
    Rails.logger.info "Evaluating MQL query: #{query}"

    parser = JiraTeamMetrics::MqlExprParser.new
    transform = MqlTransform.new
    ast = transform.apply(parser.parse(query))
    binding.pry if ast.class == Hash
    ast.eval(JiraTeamMetrics::EvalContext.new(issues))
  end

  class MqlTransform < Parslet::Transform
    rule(int: simple(:int)) do
      value = Integer(int)
      JiraTeamMetrics::ValueExpr.new(value)
    end
    rule(bool: simple(:bool)) do
      value = ActiveModel::Type::Boolean.new.cast(bool.to_s)
      JiraTeamMetrics::ValueExpr.new(value)
    end
    rule(str: simple(:str)) { JiraTeamMetrics::ValueExpr.new(str.to_s) }

    rule(ident: simple(:ident)) do
      JiraTeamMetrics::IdentExpr.new(ident.to_s)
    end

    rule(lhs: subtree(:lhs), op: '+', rhs: subtree(:rhs)) { JiraTeamMetrics::BinOpExpr.new(lhs, :+, rhs) }
    rule(lhs: subtree(:lhs), op: '-', rhs: subtree(:rhs)) { JiraTeamMetrics::BinOpExpr.new(lhs, :-, rhs) }
    rule(lhs: subtree(:lhs), op: '*', rhs: subtree(:rhs)) { JiraTeamMetrics::BinOpExpr.new(lhs, :*, rhs) }
    rule(lhs: subtree(:lhs), op: '/', rhs: subtree(:rhs)) { JiraTeamMetrics::BinOpExpr.new(lhs, :/, rhs) }

    rule(lhs: subtree(:lhs), op: 'and', rhs: subtree(:rhs)) { JiraTeamMetrics::BinOpExpr.new(lhs, :&, rhs) }
    rule(lhs: subtree(:lhs), op: 'or', rhs: subtree(:rhs)) { JiraTeamMetrics::BinOpExpr.new(lhs, :|, rhs) }

    rule(lhs: subtree(:lhs), op: '=', rhs: subtree(:rhs)) { JiraTeamMetrics::BinOpExpr.new(lhs, :==, rhs) }
  end
end
