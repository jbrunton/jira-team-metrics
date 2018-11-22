class JiraTeamMetrics::MqlInterpreter
  def eval(query)
    Rails.logger.info "Evaluating MQL query: #{query}"

    parser = JiraTeamMetrics::MqlExprParser.new
    transform = MqlTransform.new
    ast = transform.apply(parser.parse(query))
    ast.eval(nil)
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

    rule(lhs: simple(:lhs), op: '+', rhs: simple(:rhs)) { JiraTeamMetrics::BinOpExpr.new(lhs, :+, rhs) }
    rule(lhs: simple(:lhs), op: '-', rhs: simple(:rhs)) { JiraTeamMetrics::BinOpExpr.new(lhs, :-, rhs) }
    rule(lhs: simple(:lhs), op: '*', rhs: simple(:rhs)) { JiraTeamMetrics::BinOpExpr.new(lhs, :*, rhs) }
    rule(lhs: simple(:lhs), op: '/', rhs: simple(:rhs)) { JiraTeamMetrics::BinOpExpr.new(lhs, :/, rhs) }

    rule(lhs: simple(:lhs), op: 'and', rhs: simple(:rhs)) { JiraTeamMetrics::BinOpExpr.new(lhs, :&, rhs) }
    rule(lhs: simple(:lhs), op: 'or', rhs: simple(:rhs)) { JiraTeamMetrics::BinOpExpr.new(lhs, :|, rhs) }

    rule(lhs: simple(:lhs), op: '=', rhs: simple(:rhs)) { JiraTeamMetrics::BinOpExpr.new(lhs, :==, rhs) }
  end
end
