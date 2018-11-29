class JiraTeamMetrics::FuncCallExpr
  def initialize(func_name, params)
    @func_name = func_name
    @params = params
  end

  def eval(ctx)
    args = @params.map{ |param| param.eval(ctx.copy(:none)) }
    func = lookup_function(args)
    func.call(ctx, *args)
  end
private
  def lookup_function(args)
    signature = "#{@func_name}(#{args.map{ |arg| arg.class}.join(', ')})"
    func = FUNCTIONS[signature]
    if (func.nil?)
      raise JiraTeamMetrics::ParserError::UNKNOWN_FUNCTION % signature
    end
    func
  end

  FUNCTIONS = {
    'today()' => lambda { |_| DateTime.now().to_date },
    'date(String)' => lambda { |_, date_string| DateTime.parse(date_string) },
    'date(Integer, Integer, Integer)' => lambda { |_, year, month, day| DateTime.new(year, month, day) },
    'has(JiraTeamMetrics::FieldExpr::ComparisonContext)' => lambda do |_, value|
      value.not_null
    end,
    'filter(String)' => lambda do |ctx, filter_name|
      filter = ctx.board.filters.select{ |f| f.name == filter_name }.first
      if filter.nil?
        []
      else
        ctx.issues.select { |issue| filter.include?(issue) }
      end
    end
  }
end