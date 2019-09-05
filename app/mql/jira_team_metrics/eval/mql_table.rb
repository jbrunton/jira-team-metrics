class JiraTeamMetrics::Eval::MqlTable
  attr_reader :columns
  attr_reader :rows

  def initialize(columns, rows)
    @columns = columns
    @rows = rows
  end

  def to_data_table
    JiraTeamMetrics::DataTable.new(
      @columns,
      @rows.each_with_index.map do |_, row_index|
        @columns.map do |col_name|
          select_field(col_name, row_index)
        end
      end
    )
  end

  def select_field(col_name, row_index)
    row = @rows[row_index]
    if [JiraTeamMetrics::Issue, JiraTeamMetrics::Epic].include?(row.class)
      JiraTeamMetrics::IssueFieldResolver.new(row).resolve(col_name)
    else
      col_index = columns.index(col_name)
      raise JiraTeamMetrics::ParserError, "Unknown field: #{col_name}" if col_index.nil?
      row[col_index]
    end
  end

  def select_rows
    selected_rows = []
    @rows.each_with_index do |row, row_index|
      selected_rows << row if yield(row_index)
    end
    JiraTeamMetrics::Eval::MqlTable.new(@columns, selected_rows)
  end

  def map_rows(col_names)
    mapped_rows = []
    @rows.each_with_index do |_, row_index|
      mapped_rows << yield(row_index)
    end
    JiraTeamMetrics::Eval::MqlTable.new(col_names, mapped_rows)
  end

  def sort_rows(order)
    sorted_rows = @rows.each_with_index.sort_by do |_, row_index|
      yield(row_index)
    end.map{ |row, _| row }
    JiraTeamMetrics::Eval::MqlTable.new(
      @columns,
      order == 'desc' ? sorted_rows.reverse : sorted_rows)
  end

  def group_by(expr_name)
    grouped_results = @rows.each_with_index.group_by do |_, row_index|
      yield(row_index)
    end.map{ |key, rows| [key, rows.map{ |row, _| row }] }
    JiraTeamMetrics::Eval::MqlTable.new(
      [expr_name],
      grouped_results)
  end

  def self.issues_table(issues)
    JiraTeamMetrics::Eval::MqlTable.new(
      ['key', 'issuetype', 'summary', 'status', 'resolution'],
      issues
    )
  end
end