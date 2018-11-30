class JiraTeamMetrics::AST::FieldExpr
  def initialize(field_name)
    @field_name = field_name
  end

  def eval(ctx)
    if ctx.expr_type == :rhs
      raise JiraTeamMetrics::ParserError, JiraTeamMetrics::ParserError::FIELD_RHS_ERROR
    end
    ComparisonContext.new(@field_name, ctx.issues)
  end

  class ComparisonContext
    def initialize(field_name, issues)
      @field_name = field_name
      @issues = issues
    end

    def eval(op, rhs_value)
      @issues.select do |issue|
        field = JiraTeamMetrics::IssueFieldResolver.new(issue).resolve(@field_name)
        if !field.nil?
          field.send(op, rhs_value)
        else
          false
        end
      end
    end

    def not_null
      @issues.select do |issue|
        !JiraTeamMetrics::IssueFieldResolver.new(issue).resolve(@field_name).nil?
      end
    end

    def select_field
      @issues.map do |issue|
        JiraTeamMetrics::IssueFieldResolver.new(issue).resolve(@field_name)
      end
    end
  end
end