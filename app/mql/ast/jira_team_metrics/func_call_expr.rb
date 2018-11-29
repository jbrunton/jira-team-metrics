class JiraTeamMetrics::FuncCallExpr
  def initialize(func_name, params)
    @func_name = func_name
    @params = params
  end

  def eval(ctx)
    args = @params.map{ |param| param.eval(ctx.copy(:none)) }
    func = ctx.lookup_function(@func_name, args)
    func.call(ctx, *args)
  end
end