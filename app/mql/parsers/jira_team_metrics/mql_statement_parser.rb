class JiraTeamMetrics::MqlStatementParser < Parslet::Parser
  include JiraTeamMetrics::MqlLexer
  include JiraTeamMetrics::MqlOpParser
  include JiraTeamMetrics::MqlExprParser

  rule(:sort_clause) {
    str('sort by') >> space? >> (string | ident).as(:sort_by) >> space? >> (str('desc') | str('asc')).as(:order)
  }

  rule(:sort_expression) { (expression.as(:expr) >> space? >> sort_clause).as(:sort) | expression }

  root(:sort_expression)

  root :sort_expression
end