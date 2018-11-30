class JiraTeamMetrics::Eval::MqlTable
  attr_reader :columns
  attr_reader :rows

  def initialize(columns, rows)
    @columns = columns
    @rows = rows
  end

  def select_column(col_name)
    col_index = @columns.index(col_name)
    JiraTeamMetrics::Eval::MqlTable.new(
      [col_name],
      @rows.map { |row| [row[col_index]] }
    )
  end

  def select_field(col_name, row_index)
    col_index = columns.index(col_name)
    @rows[row_index][col_index]
  end

  def select_rows_by(col_name)
    @rows.select do |row|
      field_value = sele
    end
  end
end