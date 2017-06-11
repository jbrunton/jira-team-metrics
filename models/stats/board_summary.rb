class BoardSummary
  COLUMNS = [
    :issue_type,
    :count,
    :count_percentage,
    :ct_mean,
    :ct_median,
    :ct_stdded
  ]

  attr_reader :board_decorator

  def initialize(board_decorator)
    @board_decorator = board_decorator
  end

  def data

  end

end