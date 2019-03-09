class JiraTeamMetrics::DataTable
  attr_reader :columns
  attr_reader :rows

  def initialize(columns, rows)
    @columns = columns
    @rows = rows
  end

  def ==(other)
    self.class == other.class &&
      columns == other.columns &&
      rows == other.rows
  end
  alias :eql? :==

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

  def sort_by(column, &block)
    column_index = columns.index(column)
    JiraTeamMetrics::DataTable.new(
      columns,
      rows.sort_by { |row| sort_key_for(row[column_index], block) }
    )
  end

  def reverse
    JiraTeamMetrics::DataTable.new(
      columns,
      rows.reverse)
  end

  def column_values(column)
    index = columns.index(column)
    rows.map{ |row| row[index] }.compact
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

  def insert_column(column_index, column, values = nil)
    columns.insert(column_index, column)
    rows.each_with_index do |row, index|
      row.insert(column_index, values.nil? ? nil : values[index])
    end
    self
  end

  def add_column(column, values = nil)
    columns << column
    rows.each_with_index do |row, index|
      row << (values.nil? ? nil : values[index])
    end
    self
  end

  def add_row(row)
    rows << row
    self
  end

  def insert_row(index, row)
    rows.insert(index, row)
    self
  end

  def insert_if_missing(column_values, default_values, &block)
    block ||= IDENT
    InsertIfMissingOp.new(self).apply(column_values, default_values, block)
    self
  end

  def to_json(opts = {})
    JiraTeamMetrics::DataTableSerializer.new(self).to_json(opts)
  end

  def add_percentiles(column_name, percentiles)
    percentile_values = percentiles.map{ |it| column_values(column_name).percentile(it) }.reverse

    from_value = rows[0][0]
    to_value = rows[rows.count - 1][0]
    padding_columns = columns.count - 1

    percentiles.reverse.each { |it| add_column("#{it.ordinalize} percentile") }

    add_row([from_value] + Array.new(padding_columns) + percentile_values)
    add_row([to_value] + Array.new(padding_columns) + percentile_values)
  end

  class Selector
    attr_reader :data_table
    attr_reader :columns

    def initialize(data_table, columns)
      @data_table = data_table
      @columns = columns
    end

    def count(*opts)
      aggregate(opts, :count)
    end

    def sum(*opts)
      aggregate(opts, :sum)
    end

    def group(opts = {}, &block)
      group_by_columns = columns
        .select{ |column, _| col_op(column) == :id }
        .map { |column, _| column }

      aggregate_columns = columns
        .select{ |column, _| col_op(column) != :id }
        .map { |column, _| column }

      grouped_rows = group_rows_by(group_by_columns, block)
      aggregated_rows = aggregate_rows_by(grouped_rows, aggregate_columns, opts)

      JiraTeamMetrics::DataTable.new(
        columns.map { |col, col_opts| col_opts[:as] || col },
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
        pivoted_values[pivoted_columns.index(pivot_value)] = row[aggregated_index]
        row + pivoted_values
      end

      pivoted_data_table = JiraTeamMetrics::DataTable.new(
        data_table.columns + pivoted_columns,
        pivoted_rows
      )

      Selector.new(pivoted_data_table, columns)
        .group(if_nil: pivot_opts[:if_nil])
    end

  private
    def col_index(column)
      data_table.columns.index(column)
    end

    def col_op(column)
      columns[column][:op] || :id
    end

    def col_name(column)
      columns[column][:as] || column
    end

    def aggregate(opts, op)
      if opts.length == 1 && opts[0].is_a?(Array)
        opts[0].each { |column| count(column) }
      else
        column = opts[0]
        column_opts = opts[1] || {}
        @columns[column] = { op: op }.merge(column_opts)
      end
      self
    end

    def group_rows_by(group_by_columns, block)
      data_table.rows.group_by do |row|
        group_by_values = group_by_columns.map{ |column| row[col_index(column)] }
        if block.nil?
          group_by_values
        else
          apply_group_by_block(group_by_values, block)
        end
      end
    end

    def apply_group_by_block(group_by_values, block)
      result = block.call(*group_by_values)
      # so that we can write .group{ |x| x.y } instead of .group{ |x| [x.y] } when grouping by a single value
      result.is_a?(Array) ? result : [result]
    end

    def aggregate_rows_by(grouped_rows, aggregate_columns, opts)
      grouped_rows.map do |group_by_values, rows|
        group_by_values + aggregate_columns.map do |column|
          column_values = rows.map{ |row| row[col_index(column)] }.compact
          column_values.empty? ? opts[:if_nil] : column_values.send(col_op(column))
        end
      end
    end
  end

private
  def sort_key_for(val, block)
    if val.nil?
      [0, nil]
    else
      [1, block.nil? ? val : block.call(val)]
    end
  end

  class InsertIfMissingOp
    attr_reader :data_table

    def initialize(data_table)
      @data_table = data_table
    end

    def apply(column_values, default_values, block)
      remaining_values = column_values.clone
      row_index = 0
      while remaining_values.any?
        if row_index >= data_table.rows.count
          insert_remaining_values(remaining_values, default_values)
        else
          insert_next_value(row_index, remaining_values, default_values, block)
          row_index += 1
        end
      end
    end

  private
    def insert_remaining_values(remaining_values, default_values)
      data_table.rows.concat(remaining_values.map{ |val| [val] + default_values })
      remaining_values.clear
    end

    def insert_next_value(row_index, remaining_values, default_values, block)
      value_to_insert = remaining_values.first
      value_at_index = data_table.rows.count > row_index ? data_table.rows[row_index][0] : nil
      if block.call(value_to_insert) < block.call(value_at_index)
        data_table.insert_row(row_index, [value_to_insert] + default_values)
        remaining_values.shift
      elsif block.call(value_to_insert) == block.call(value_at_index)
        remaining_values.shift
      end
    end
  end

  IDENT = Proc.new{ |x| x }
end