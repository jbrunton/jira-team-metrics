class JiraTeamMetrics::FuncCallExpr
  def initialize(func_name)
    @func_name = func_name
  end

  def eval(ctx)
    func = FUNCTIONS[@func_name]
    if (func.nil?) then
      raise JiraTeamMetrics::ParserError::UNKNOWN_FUNCTION % @func_name
    end
    func.call()
  end
private
  FUNCTIONS = {
    'today' => lambda { DateTime.now().to_date }
  }
end