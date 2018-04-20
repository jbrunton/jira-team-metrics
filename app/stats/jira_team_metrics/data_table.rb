class JiraTeamMetrics::DataTable
  attr_reader :columns
  attr_reader :rows

  def initialize(columns, rows)
    @columns = columns
    @rows = rows
  end

  def group_by(aggregate_column, operation, opts)
    expression_column, expression_name = opts.values_at(:of, :as)
    aggregate_index = columns.index(aggregate_column)
    expression_index = columns.index(expression_column)

    grouped_data = rows
      .group_by { |row| row[aggregate_index] }
      .map { |aggregator_value, rows| aggregate(aggregator_value, expression_index, operation, rows) }

    JiraTeamMetrics::DataTable.new(
      [aggregate_column, expression_name],
      grouped_data)
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
  def aggregate(aggregator_value, expression_index, operation, rows)
    [
      aggregator_value,
      rows.map{ |row| row[expression_index] }.compact.send(operation)
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