class JiraTeamMetrics::EvalContext
  attr_reader :board
  attr_reader :issues
  attr_reader :expr_type

  def initialize(board, issues, expr_type = :none)
    @board = board
    @issues = issues
    @expr_type = expr_type
  end

  def copy(opts = {})
    JiraTeamMetrics::EvalContext.new(
      board,
      opts[:issues] || issues,
      opts[:expr_type] || expr_type
    )
  end
end