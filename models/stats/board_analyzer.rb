class BoardAnalyzer
  def initialize(board, from_state, to_state)
    @board = board
    @from_state = from_state
    @to_state = to_state
  end

  def completed_issues
    @completed_issues ||= @board.issues
      .select{ |i| i.completed && i.started }
      .map{ |i| IssueDecorator.new(i, @from_state, @to_state) }
  end

  def max_cycle_time
    @max_cycle_time ||= completed_issues.map{ |i| i.cycle_time }.compact.max
  end
end