class DataTableBuilder
  def initialize
    @cols = []
    @rows = []
  end

  def column(opts)
    @cols << opts
    self
  end

  def number_column(opts)
    column(opts.merge(type: 'number'))
  end

  def interval_column(opts)
    number_column(opts.merge(role: 'interval'))
  end

  def row(values)
    @rows << {c: values.map{ |v| {v: v} }}
    self
  end

  def build
    {
      cols: @cols,
      rows: @rows
    }
  end
end