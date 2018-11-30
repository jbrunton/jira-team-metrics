class JiraTeamMetrics::Eval::MqlAbstractTable
  attr_reader :rows

  def initialize(rows)
    @rows = rows
  end

  def select_column(col_name)
    raise NotImplementedError
  end

  def select_field(col_name, row_index)
    raise NotImplementedError
  end
end