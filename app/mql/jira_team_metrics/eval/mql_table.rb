class JiraTeamMetrics::Eval::MqlTable
  attr_reader :columns
  attr_reader :rows

  def initialize(columns, rows)
    @columns = columns
    @rows = rows
  end

  def select_field(col_name, row_index)
    col_index = columns.index(col_name)
    @rows[row_index][col_index]
  end

  def select_rows
    selected_rows = []
    @rows.each_with_index do |row, row_index|
      selected_rows << row if yield(row_index)
    end
    JiraTeamMetrics::Eval::MqlTable.new(@columns, selected_rows)
  end
end