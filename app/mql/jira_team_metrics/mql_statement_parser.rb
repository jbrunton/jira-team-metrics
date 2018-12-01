class JiraTeamMetrics::MqlStatementParser < Parslet::Parser
  include JiraTeamMetrics::MqlLexer
  include JiraTeamMetrics::MqlOpParser
  include JiraTeamMetrics::MqlExprParser

  rule(:sort_clause) {
    str('sort by') >>
      space? >> (string | ident).as(:expr) >>
      space? >> (str('desc') | str('asc')).as(:order)
  }

  rule(:expression_stmt) { expression.as(:expr) }

  rule(:sort_stmt) do
    (expression.as(:expr) >> space? >> sort_clause).as(:sort)
  end

  rule(:select_statement) do
    str('select') >> space? >> (str('*') | expression_list.as(:select_exprs)) >> space? >>
      str('from') >> space? >> function_call.as(:from) >> space? >>
      (str('where') >> space? >> expression.as(:expr)).maybe.as(:where) >> space? >>
      (str('sort by') >> space? >> expression.as(:expr) >> space? >> (str('asc') | str('desc')).as(:order)).maybe.as(:sort) >> space?
  end

  rule(:statement) do
    select_statement.as(:stmt) | expression_stmt.as(:stmt)
  end

  root :statement
end
