class JiraTeamMetrics::AST::BinOpExpr
  attr_reader :lhs
  attr_reader :op
  attr_reader :rhs

  def initialize(lhs, op, rhs)
    @lhs = lhs
    @op = op
    @rhs = rhs
  end

  def eval(ctx)
    lhs_value = @lhs.eval(ctx)
    rhs_value = @rhs.eval(ctx)
    if lhs_value.nil?
      nil
    else
      lhs_value.send(@op, rhs_value)
    end
  end

  def expr_name
    name = "#{@lhs.expr_name} #{@op} #{@rhs.expr_name}"
    if @lhs.class == JiraTeamMetrics::AST::ValueExpr &&
      @rhs.class == JiraTeamMetrics::AST::ValueExpr
    then
      name
    else
      "(#{name})"
    end
  end
end
