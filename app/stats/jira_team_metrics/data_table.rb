class JiraTeamMetrics::DataTable
  attr_reader :columns
  attr_reader :rows

  def initialize(columns, rows)
    @columns = columns
    @rows = rows
  end

  def group_by(expression_opts, operation, opts)
    if expression_opts.is_a?(Array)
      expression_columns = expression_opts
    else
      expression_columns = [expression_opts]
    end
    aggregate_column, aggregate_name = opts.values_at(:of, :as)
    expression_indexes = expression_columns.map { |expression_column| columns.index(expression_column) }
    aggregate_index = columns.index(aggregate_column)

    grouped_data = rows
      .group_by { |row| expression_indexes.map{ |expression_index| row[expression_index] } }
      .map { |expression_values, rows| aggregate(expression_values, aggregate_index, operation, rows) }

    JiraTeamMetrics::DataTable.new(
      expression_columns + [aggregate_name],
      grouped_data)
  end

  def sort_by(column, sort_order)
    index = columns.index(column)
    sort_factor = sort_order == :desc ? -1 : 1
    JiraTeamMetrics::DataTable.new(
      columns,
      rows.sort_by{ |row| row[index] * sort_factor }
    )
  end

  def pivot_on(pivot_column, opts)
    pivot_column_index = columns.index(pivot_column)
    pivot_column_values = rows.map{ |row| row[pivot_column_index] }.uniq
    select_column = opts[:select]
    select_column_index = columns.index(select_column)

    retained_columns = columns.select do |column|
      ![pivot_column, select_column].include?(column)
    end

    pivot_columns = retained_columns + pivot_column_values

    pivot_hash = {}
    pivot_hash_key_indexes = retained_columns.map { |column| columns.index(column) }

    rows.each do |row|
      pivot_key = row.values_at(*pivot_hash_key_indexes)
      pivot_value = row[pivot_column_index]
      pivot_hash[pivot_key] ||= {}
      pivot_hash[pivot_key][pivot_value] = row[select_column_index]
    end

    pivot_rows = pivot_hash.map do |pivot_key, pivot_value_hash|
      pivot_key + pivot_column_values.map do |val|
        pivot_value_hash[val] || opts[:if_nil]
      end
    end

    JiraTeamMetrics::DataTable.new(
      pivot_columns,
      pivot_rows
    )
  end

  def to_json
    {
      'cols' => columns.each_with_index.map do |column_name, column_index|
        { 'label' => column_name, 'type' => column_type(column_index) }
      end,
      'rows' => rows.map { |row| { 'c' => row.map { |x| { 'v' => x } } } }
    }
  end

private
  def aggregate(expression_values, aggregate_index, operation, rows)
    expression_values + [
      rows.map{ |row| row[aggregate_index] }.compact.send(operation)
    ]
  end

  def column_type(index)
    types = rows.map{ |row| row[index] }.compact.map{ |v| v.class }.uniq
    if types.count == 1 && types[0] <= Numeric
      return 'number'
    end
    'string'
  end
end