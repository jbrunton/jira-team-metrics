class JiraTeamMetrics::MqlExprParser < Parslet::Parser
  include JiraTeamMetrics::MqlLexer

  rule(:lparen) { str("(") >> space? }
  rule(:rparen) { str(")") >> space? }

  rule(:expression) { binop | primary_expression }
  rule(:primary_expression) { lparen >> expression >> rparen | int | bool }

  rule(:mul_op) { match['*/'].as(:op) >> space? }
  rule(:add_op) { match['+-'].as(:op) >> space? }
  rule(:eq_op) { str('=').as(:op) >> space? }
  rule(:and_op) { str('and').as(:op) >> space? }
  rule(:or_op) { str('or').as(:op) >> space? }
  rule(:binop) {
    infix_expression(primary_expression,
        [and_op, 5, :left],
        [or_op, 4, :left],
        [eq_op, 3, :left],
        [mul_op, 2, :left],
        [add_op, 1, :left]
    ) { |l, o, r| {lhs: l, op: o[:op], rhs: r} }
  }

  root :expression
end