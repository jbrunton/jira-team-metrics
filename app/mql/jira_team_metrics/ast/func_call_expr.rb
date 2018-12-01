class JiraTeamMetrics::AST::FuncCallExpr
  def initialize(func_name, params)
    @func_name = func_name
    @params = params
  end

  def eval(ctx)
    args = @params.map{ |param| param.eval(ctx) }
    func = ctx.lookup_function(@func_name, args)
    func.call(ctx, *args)
  end

  def expr_name
    "#{@func_name}()"
  end
end