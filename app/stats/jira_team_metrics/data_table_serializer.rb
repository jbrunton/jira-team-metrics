class JiraTeamMetrics::DataTableSerializer
  include JiraTeamMetrics::ChartsHelper

  def initialize(data_table)
    @data_table = data_table
  end

  def to_json(opts = {})
    json_cols = columns(opts)
    json_rows = rows(json_cols)
    {
      'cols' => json_cols,
      'rows' => json_rows
    }
  end

private
  def columns(opts)
    @data_table.columns.each_with_index.map do |column_name, column_index|
      column_opts = opts[column_name] || {}
      json_col = {
        'label' => column_opts[:as] || column_name,
        'type' => column_opts[:type] || column_type(column_index)
      }
      json_col.merge!('role' => column_opts[:role]) unless column_opts[:role].nil?
      json_col
    end
  end

  def rows(json_cols)
    @data_table.rows.map do |row|
      {
        'c' => row.each_with_index.map do |val, column_index|
          if ['date', 'datetime'].include?(json_cols[column_index]['type'])
            json_val = date_as_string(val)
          else
            json_val = val
          end
          { 'v' => json_val }
        end
      }
    end
  end

  def column_type(index)
    column_values = @data_table.rows.map{ |row| row[index] }.compact
    if numeric_column?(column_values)
      'number'
    elsif date_column?(column_values)
      'date'
    elsif column_values.empty?
      # play it safe with google charts - assume a number unless clearly not
      'number'
    else
      'string'
    end
  end

  def numeric_column?(column_values)
    column_values.any? && column_values.all?{ |val| val.class <= Numeric }
  end

  def date_column?(column_values)
    column_values.any? && column_values.all?{ |val| val.class <= Time || val.class <= Date || val.class <= DateTime }
  end
end