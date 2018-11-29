class JiraTeamMetrics::FieldExpr
  def initialize(field_name)
    @field_name = field_name
  end

  def eval(ctx)
    if (ctx.expr_type == :rhs) then
      raise JiraTeamMetrics::ParserError, JiraTeamMetrics::ParserError::FIELD_RHS_ERROR
    end
    ComparisonContext.new(@field_name, ctx.issues)
  end

  class ComparisonContext
    def initialize(field_name, issues)
      @field_name = field_name
      @issues = issues
    end

    def ==(value)
      @issues.select do |issue|
        JiraTeamMetrics::IssueFieldResolver.new(issue).resolve(@field_name) == value
      end
    end

  end
end