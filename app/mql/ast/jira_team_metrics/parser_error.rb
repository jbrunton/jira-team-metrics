class JiraTeamMetrics::ParserError < RuntimeError
  IDENT_RHS_ERROR = "Identifiers must only occur on the left hand side of comparisons"
end