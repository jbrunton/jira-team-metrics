class JiraTeamMetrics::MqlInterpreter
  def eval(query)
    Rails.logger.info "Evaluating MQL query: #{query}"

    parser = JiraTeamMetrics::MqlExprParser.new
    transform = MqlTransform.new
    transform.apply(parser.parse(query))
  end

  class MqlTransform < Parslet::Transform
    rule(int: simple(:int)) { Integer(int) }
    rule(lhs: simple(:lhs), op: '+', rhs: simple(:rhs)) { lhs + rhs }
    rule(lhs: simple(:lhs), op: '-', rhs: simple(:rhs)) { lhs - rhs }
    rule(lhs: simple(:lhs), op: '*', rhs: simple(:rhs)) { lhs * rhs }
    rule(lhs: simple(:lhs), op: '/', rhs: simple(:rhs)) { lhs / rhs }
  end
end
