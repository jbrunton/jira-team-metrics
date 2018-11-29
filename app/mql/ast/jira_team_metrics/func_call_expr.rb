class JiraTeamMetrics::FuncCallExpr
  def initialize(func_name, args)
    @func_name = func_name
    @args = args
  end

  def eval(ctx)
    params = @args.map{ |arg| arg.eval(ctx) }
    signature = "#{@func_name}(#{params.map{ |arg| arg.class}.join(',')})"
    func = FUNCTIONS[signature]
    if (func.nil?) then
      raise JiraTeamMetrics::ParserError::UNKNOWN_FUNCTION % signature
    end
    func.call(*params)
  end
private
  FUNCTIONS = {
    'today()' => lambda { DateTime.now().to_date },
    'date(String)' => lambda { |date_string| DateTime.parse(date_string) }
  }
end