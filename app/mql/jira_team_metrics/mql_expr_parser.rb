module JiraTeamMetrics::MqlExprParser
  include Parslet
  include JiraTeamMetrics::MqlLexer
  include JiraTeamMetrics::MqlOpParser

  rule(:lparen) { str("(") >> space? }
  rule(:rparen) { str(")") >> space? }
  rule(:comma) { str(",") >> space? }

  rule(:field) { ident.as(:field) }
  rule(:expression_list_item) { as_expression | expression  }
  rule(:expression_list) { expression_list_item.repeat(1,1) >> (comma >> expression_list_item).repeat }
  rule(:function_call) { (ident >> lparen >> (expression_list.repeat(0,1)).as(:args) >> rparen).as(:fun) }
  rule(:not_expression) { str('not') >> space? >> expression.as(:not) }

  rule(:as_expression) { (primary_expression.as(:expr) >> space? >> str('as') >> space? >> field.as(:name) >> space?).as(:as) }

  rule(:expression) { binop | primary_expression }
  rule(:primary_expression) do
    lparen >> expression >> rparen |
      not_expression |
      function_call |
      int |
      bool |
      field |
      string
  end
end