class JiraTeamMetrics::MqlExprParser < Parslet::Parser
  include JiraTeamMetrics::MqlLexer

  rule(:lparen) { str("(") >> space? }
  rule(:rparen) { str(")") >> space? }

  rule(:expression) { lparen >> expression >> rparen | binop | integer }

  rule(:mul_op) { match['*/'].as(:op) >> space? }
  rule(:add_op) { match['+-'].as(:op) >> space? }
  rule(:binop) {
    infix_expression(integer,
      [mul_op, 2, :left],
      [add_op, 1, :right]) { |l, o, r| {lhs: l, op: o[:op], rhs: r} }
  }

  root :expression
end