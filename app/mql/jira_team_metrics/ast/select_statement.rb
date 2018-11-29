class JiraTeamMetrics::AST::SelectStatement
  def initialize(data_source, expr)
    @data_source = data_source
    @expr = expr
  end

  def eval(ctx)
    issues = @data_source.eval(ctx)
    if @expr.nil?
      issues
    else
      @expr.eval(ctx.copy(:none, issues: issues))
    end
  end
end