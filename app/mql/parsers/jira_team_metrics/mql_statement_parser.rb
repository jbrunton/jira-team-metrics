class JiraTeamMetrics::MqlStatementParser < Parslet::Parser
  include JiraTeamMetrics::MqlLexer
  include JiraTeamMetrics::MqlOpParser
  include JiraTeamMetrics::MqlExprParser

  rule(:sort_clause) {
    str('sort by') >>
      space? >> (string | ident).as(:sort_by) >>
      space? >> (str('desc') | str('asc')).as(:order)
  }

  rule(:sort_expression) do
    (expression.as(:expr) >> space? >> sort_clause).as(:sort) | expression
  end

  rule(:select_statement) do
    str('select') >> space? >> str('*') >> space? >>
      str('from') >> space? >> function_call.as(:from) >> space? >>
      str('where') >> space? >> sort_expression.as(:where)
  end

  rule(:statement) do
    select_statement.as(:stmt) | sort_expression
  end

  root :statement
end
