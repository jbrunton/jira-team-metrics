class JiraTeamMetrics::IdentExpr
  def initialize(field_name)
    @field_name = field_name
  end

  def eval(ctx)
    ComparisonContext.new(@field_name, ctx.issues)
  end

  class ComparisonContext
    def initialize(field_name, issues)
      @field_name = field_name
      @issues = issues
    end

    def ==(value)
      @issues.select do |issue|
        issue.send(@field_name) == value
      end
    end

  end
end