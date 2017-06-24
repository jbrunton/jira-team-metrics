class DataTableBuilder
  def initialize
    @cols = []
    @rows = []
  end

  def column(opts)
    @cols << opts
    self
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