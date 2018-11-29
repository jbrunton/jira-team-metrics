module JiraTeamMetrics::MqlOpParser
  include Parslet
  include JiraTeamMetrics::MqlLexer

  rule(:mul_op) { match['*/'].as(:op) >> space? }
  rule(:add_op) { match['+-'].as(:op) >> space? }
  rule(:ineq_op) { (str('<=') | str('>=') | match['<>']).as(:op) >> space? }
  rule(:eq_op) { str('=').as(:op) >> space? }
  rule(:and_op) { str('and').as(:op) >> space? }
  rule(:or_op) { str('or').as(:op) >> space? }

  rule(:binop) {
    infix_expression(primary_expression,
      [mul_op,  6, :left],
      [add_op,  5, :left],
      [ineq_op, 4, :left],
      [eq_op,   3, :left],
      [and_op,  2, :left],
      [or_op,   1, :left]
    ) { |l, o, r| {lhs: l, op: o[:op], rhs: r} }
  }
end