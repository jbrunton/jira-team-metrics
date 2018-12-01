class JiraTeamMetrics::MqlStatementParser < Parslet::Parser
  include JiraTeamMetrics::MqlLexer
  include JiraTeamMetrics::MqlOpParser
  include JiraTeamMetrics::MqlExprParser

  rule(:expression_stmt) { expression.as(:expr) }

  rule(:select_clause) do
    (str('select') >> space? >>
      (str('*').as(:op) | expression_list.as(:exprs)) >> space?
    ).as(:select_clause)
  end

  rule(:from_clause) do
    (str('from') >> space? >>
      function_call.as(:data_source) >> space?
    ).as(:from_clause)
  end

  rule(:where_clause) do
    (str('where') >> space? >>
      expression.as(:expr) >> space?
    ).as(:where_clause)
  end

  rule(:sort_clause) do
    (str('sort by') >> space? >>
      expression.as(:expr) >> space? >>
      (str('asc') | str('desc')).as(:order) >> space?
    ).as(:sort_clause)
  end

  rule(:select_statement) do
    select_clause.as(:select) >> space? >>
      from_clause.as(:from) >> space? >>
      where_clause.maybe.as(:where) >> space? >>
      sort_clause.maybe.as(:sort) >> space?
  end

  rule(:statement) do
    select_statement.as(:stmt) | expression_stmt.as(:stmt)
  end

  root :statement
end
