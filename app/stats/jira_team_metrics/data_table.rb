class JiraTeamMetrics::DataTable
  include JiraTeamMetrics::ChartsHelper

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

  def add_column(column)
    columns << column
    rows.each do |row|
      row << nil
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

  def to_json(opts = {})
    json_cols = columns.each_with_index.map do |column_name, column_index|
      column_opts = opts[column_name] || {}
      json_col = {
        'label' => column_opts[:as] || column_name,
        'type' => column_opts[:type] || column_type(column_index)
      }
      json_col.merge!('role' => column_opts[:role]) unless column_opts[:role].nil?
      json_col
    end
    json_rows = rows.map do |row|
      {
        'c' => row.each_with_index.map do |val, column_index|
          if json_cols[column_index]['type'] == 'date'
            json_val = date_as_string(val)
          else
            json_val = val
          end
          { 'v' => json_val }
        end
      }
    end
    {
      'cols' => json_cols,
      'rows' => json_rows
    }
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
          block.call(*group_by_values)
        end
      end
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
  def column_type(index)
    column_values = rows.map{ |row| row[index] }.compact
    if column_values.any? && column_values.all?{ |val| val.class <= Numeric }
      'number'
    elsif column_values.any? && column_values.all?{ |val| val.class <= Time }
      'date'
    elsif column_values.empty?
      # play it safe with google charts - assume a number unless clearly not
      'number'
    else
      'string'
    end
  end

  def sort_key_for(val, block)
    if val.nil?
      [0, nil]
    else
      [1, block.nil? ? val : block.call(val)]
    end
  end
end