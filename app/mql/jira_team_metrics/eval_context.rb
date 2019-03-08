class JiraTeamMetrics::EvalContext
  attr_reader :board
  attr_reader :table
  attr_reader :row_index

  def initialize(board, table, row_index = nil, functions = nil)
    @board = board
    @table = table
    @row_index = row_index
    @functions = functions || {}
  end

  def copy(table, row_index = nil)
    JiraTeamMetrics::EvalContext.new(
      @board,
      table || @table,
      row_index || @row_index,
      @functions)
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
    func ||= begin
      varargs_signature = "#{func_name}(*)"
      @functions[varargs_signature]
    end
    if func.nil?
      raise JiraTeamMetrics::ParserError::UNKNOWN_FUNCTION % signature
    end
    func
  end

  def self.build(board, issues)
    table = issues ? JiraTeamMetrics::Eval::MqlTable.issues_table(issues) : nil
    context = JiraTeamMetrics::EvalContext.new(board, table)

    # aggregation functions
    JiraTeamMetrics::Fn::CountAll.register(context)

    # date functions
    JiraTeamMetrics::Fn::DateToday.register(context)
    JiraTeamMetrics::Fn::DateConstructor.register(context)
    JiraTeamMetrics::Fn::DateParser.register(context)

    # data sources
    JiraTeamMetrics::Fn::DataSource.register(context)

    # misc.
    JiraTeamMetrics::Fn::NotNullCheck.register(context)
    JiraTeamMetrics::Fn::IssueFilter.register(context)
    JiraTeamMetrics::Fn::Coalesce.register(context)

    context
  end
end