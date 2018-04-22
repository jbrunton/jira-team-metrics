class JiraTeamMetrics::DataTable
  attr_reader :columns
  attr_reader :rows

  def initialize(columns, rows)
    @columns = columns
    @rows = rows
  end

  def select(*opts)
    if opts.empty?
      columns = {}
    elsif opts.count == 1 && opts[0].is_a?(Hash)
      columns = opts[0]
    else
      columns = opts.map{ |column| [column, {}] }.to_h
    end
    Selector.new(self, columns)
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
      .group_by do |row|
        group_by_values = expression_indexes.map{ |expression_index| row[expression_index] }
        if block_given?
          yield(*group_by_values)
        else
          group_by_values
        end
      end
      .map do |expression_values, rows|
        aggregate(expression_values, aggregate_index, operation, rows)
      end

    JiraTeamMetrics::DataTable.new(
      expression_columns + [aggregate_name],
      grouped_data)
  end

  def sort_by(column)
    index = columns.index(column)
    JiraTeamMetrics::DataTable.new(
      columns,
      rows.sort_by do |row|
        val = row[index]
        sort_val = block_given? ? yield(val) : val
        [val.nil? ? 0 : 1, sort_val]
      end
    )
  end

  def reverse
    JiraTeamMetrics::DataTable.new(
      columns,
      rows.reverse)
  end

  def map(column)
    column_index = columns.index(column)
    new_rows = rows.map do |row|
      row.each_with_index.map do |val, index|
        index == column_index ? yield(val) : val
      end
    end
    JiraTeamMetrics::DataTable.new(columns, new_rows)
  end

  def pivot_on(pivot_column, opts)
    pivot_column_index = columns.index(pivot_column)
    pivot_column_values = opts[:from]
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

  class Selector
    attr_reader :data_table
    attr_reader :columns

    def initialize(data_table, columns)
      @data_table = data_table
      @columns = columns
    end

    def count(column, opts = {})
      @columns[column] = { op: :count }.merge(opts)
      self
    end

    def sum(column, opts = {})
      @columns[column] = { op: :sum }.merge(opts)
      self
    end

    def group
      group_by_columns = columns
        .select{ |column, _| col_op(column) == :id }
        .map { |column, _| column }

      aggregate_columns = columns
        .select{ |column, _| col_op(column) != :id }
        .map { |column, _| column }

      grouped_rows = data_table.rows.group_by do |row|
        group_by_values = group_by_columns.map{ |column| row[col_index(column)] }
        if block_given?
          yield(*group_by_values)
        else
          group_by_values
        end
      end

      aggregated_rows = grouped_rows.map do |group_by_values, rows|
        group_by_values + aggregate_columns.map do |column|
          rows.map{ |row| row[col_index(column)] }.compact.send(col_op(column))
        end
      end

      JiraTeamMetrics::DataTable.new(
        columns.map { |col, opts| opts[:as] || col },
        aggregated_rows
      )
    end

    def pivot(aggregated_column, pivot_opts)
      pivot_column = pivot_opts[:for]
      pivoted_columns = pivot_opts[:in]
      pivot_index = col_index(pivot_column)
      aggregated_index = col_index(aggregated_column)

      pivoted_rows = data_table.rows.map do |row|
        pivot_value = row[pivot_index]
        pivoted_values = Array.new(pivoted_columns.count)
        pivoted_values[pivoted_columns.index(pivot_value)] = row[aggregated_index] || opts[:if_nil]
        row + pivoted_values
      end

      pivoted_data_table = JiraTeamMetrics::DataTable.new(
        data_table.columns + pivoted_columns,
        pivoted_rows
      )
      Selector.new(pivoted_data_table, columns).group
    end

  #private
    def col_index(column)
      data_table.columns.index(column)
    end

    def col_op(column)
      columns[column][:op] || :id
    end

    def col_name(column)
      columns[column][:as] || column
    end
  end

  class PivotSelector
    attr_reader :selector
    attr_reader :pivot_column # column we're pivoting on
    attr_reader :aggregate_op # operation we're aggregating with
    attr_reader :aggregated_column # column we're aggregating
    attr_reader :pivoted_columns # columns we're creating from pivot_column values

    def initialize(selector, pivot_column)
      @selector = selector
      @pivot_column = pivot_column
    end

    def count(aggregated_column)
      @aggregate_op = :count
      @aggregated_column = aggregated_column
      self
    end

    def sum(aggregated_column)
      @aggregate_op = :sum
      @aggregated_column = aggregated_column
      self
    end

    def from(*pivoted_columns)
      @pivoted_columns = pivoted_columns
      build
    end

  private
    def build
      pivot_index = selector.col_index(pivot_column)
      aggregated_index = selector.col_index(aggregated_column)

      pivoted_rows = selector.data_table.rows.map do |row|
        pivot_value = row[pivot_index]
        pivoted_values = Array.new(pivoted_columns)
        pivoted_values[pivoted_columns.index(pivot_value)] = row[aggregated_index]
        row + pivoted_values
      end

      pivoted_data_table = JiraTeamMetrics::DataTable.new(
        selector.data_table.columns + pivoted_columns,
        pivoted_rows
      )
      Selector.new(pivoted_data_table, selector.columns + pivoted_columns).group
    end
  end

private
  def aggregate(expression_values, aggregate_index, operation, rows)
    expression_values + [
      rows.map{ |row| row[aggregate_index] }.compact.send(operation)
    ]
  end

  def column_type(index)
    column_values = rows.map{ |row| row[index] }.compact
    if column_values.any? && column_values.all?{ |val| val.class <= Numeric }
      'number'
    else
      'string'
    end
  end
end