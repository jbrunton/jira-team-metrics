class JiraTeamMetrics::MqlExprParser < Parslet::Parser
  include JiraTeamMetrics::MqlLexer

  rule(:lparen) { str("(") >> space? }
  rule(:rparen) { str(")") >> space? }

  rule(:expression) { binop | primary_expression }
  rule(:primary_expression) { lparen >> expression >> rparen | integer }

  rule(:mul_op) { match['*/'].as(:op) >> space? }
  rule(:add_op) { match['+-'].as(:op) >> space? }
  rule(:binop) {
    infix_expression(primary_expression,
      [mul_op, 2, :left],
      [add_op, 1, :right]) { |l, o, r| {lhs: l, op: o[:op], rhs: r} }
  }

  root :expression
end