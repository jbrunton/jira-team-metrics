class JiraTeamMetrics::FuncCallExpr
  def initialize(func_name, args)
    @func_name = func_name
    @args = args
  end

  def eval(ctx)
    params = @args.map{ |arg| arg.eval(ctx) }
    signature = "#{@func_name}(#{params.map{ |arg| arg.class}.join(', ')})"
    func = FUNCTIONS[signature]
    if (func.nil?)
      raise JiraTeamMetrics::ParserError::UNKNOWN_FUNCTION % signature
    end
    func.call(ctx, *params)
  end
private
  FUNCTIONS = {
    'today()' => lambda { |_| DateTime.now().to_date },
    'date(String)' => lambda { |_, date_string| DateTime.parse(date_string) },
    'date(Integer, Integer, Integer)' => lambda { |_, year, month, day| DateTime.new(year, month, day) },
    'filter(String)' => lambda do |ctx, filter_name|
      filter = ctx.board.filters.select{ |f| f.name == filter_name }.first
      ctx.issues.select do |issue|
        filter.include?(issue)
      end
    end
  }
end