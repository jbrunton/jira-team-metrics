class JiraTeamMetrics::MqlExprParser < Parslet::Parser
  include JiraTeamMetrics::MqlLexer

  rule(:lparen) { str("(") >> space? }
  rule(:rparen) { str(")") >> space? }
  rule(:comma) { str(",") >> space? }

  rule(:field) { ident.as(:field) }
  #rule(:expression_list) { primary_expression >> (comma >> primary_expression).repeat }
  rule(:function_call) { ident.as(:fun) >> lparen >> rparen }

  rule(:expression) { binop | primary_expression }
  rule(:primary_expression) do
    lparen >> expression >> rparen |
      function_call |
      int |
      bool |
      field |
      string
  end

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