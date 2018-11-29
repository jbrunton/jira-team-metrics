module JiraTeamMetrics::MqlExprParser
  include Parslet
  include JiraTeamMetrics::MqlLexer
  include JiraTeamMetrics::MqlOpParser

  rule(:lparen) { str("(") >> space? }
  rule(:rparen) { str(")") >> space? }
  rule(:comma) { str(",") >> space? }

  rule(:field) { ident.as(:field) }
  rule(:expression_list) { primary_expression >> (comma >> primary_expression).repeat }
  rule(:function_call) { (ident >> lparen >> (expression_list.repeat(0,1)).as(:args) >> rparen).as(:fun) }
  rule(:not_expression) { str('not') >> space? >> expression.as(:not) }

  rule(:expression) { binop | primary_expression }
  rule(:primary_expression) do
    lparen >> expression >> rparen |
      function_call |
      not_expression |
      int |
      bool |
      field |
      string
  end
end