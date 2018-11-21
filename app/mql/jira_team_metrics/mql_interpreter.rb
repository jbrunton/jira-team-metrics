class JiraTeamMetrics::MqlInterpreter
  def eval(query)
    Rails.logger.info "Evaluating MQL query: #{query}"

    parser = JiraTeamMetrics::MqlExprParser.new
    transform = MqlTransform.new
    transform.apply(parser.parse(query))
  end

  class MqlTransform < Parslet::Transform
    rule(int: simple(:int)) { Integer(int) }
    rule(bool: simple(:bool)) { ActiveModel::Type::Boolean.new.cast(bool.to_s) }

    rule(lhs: simple(:lhs), op: '+', rhs: simple(:rhs)) { lhs + rhs }
    rule(lhs: simple(:lhs), op: '-', rhs: simple(:rhs)) { lhs - rhs }
    rule(lhs: simple(:lhs), op: '*', rhs: simple(:rhs)) { lhs * rhs }
    rule(lhs: simple(:lhs), op: '/', rhs: simple(:rhs)) { lhs / rhs }

    rule(lhs: simple(:lhs), op: 'and', rhs: simple(:rhs)) { lhs && rhs }
    rule(lhs: simple(:lhs), op: 'or', rhs: simple(:rhs)) { lhs || rhs }
  end
end
