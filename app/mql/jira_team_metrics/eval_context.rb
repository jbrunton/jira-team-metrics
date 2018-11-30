class JiraTeamMetrics::EvalContext
  attr_reader :board
  attr_reader :table
  attr_reader :expr_type

  def initialize(board, table, expr_type = :none, functions = {})
    @board = board
    @table = table
    @expr_type = expr_type
    @functions = functions
  end

  def copy(expr_type, opts = {})
    JiraTeamMetrics::EvalContext.new(
      board,
      opts[:table] || @table,
      expr_type,
      @functions
    )
  end

  def register_function(signature, function)
    @functions[signature] = function
  end

  def lookup_function(func_name, args)
    signature = "#{func_name}(#{args.map{ |arg| arg.class}.join(', ')})"
    func = @functions[signature] ||= begin
      generic_signature = "#{func_name}(#{Array.new(args.count, 'Object').join(', ')})"
      @functions[generic_signature]
    end
    if func.nil?
      raise JiraTeamMetrics::ParserError::UNKNOWN_FUNCTION % signature
    end
    func
  end
end