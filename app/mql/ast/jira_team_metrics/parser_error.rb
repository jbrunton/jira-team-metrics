class JiraTeamMetrics::ParserError < RuntimeError
  FIELD_RHS_ERROR = "Fields must only occur on the left hand side of comparisons"
  UNKNOWN_FUNCTION = "Function does not exist: %1s"
end
