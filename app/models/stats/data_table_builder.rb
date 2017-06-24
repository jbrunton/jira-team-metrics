class DataTableBuilder
  def initialize
    @cols = []
    @rows = []
  end

  def column(opts)
    @cols << opts
    self
  end

  def number(opts)
    column(opts.merge(type: 'number'))
  end

  def interval(opts)
    number(opts.merge(role: 'interval'))
  end

  def intervals(ids)
    ids.each{ |id| interval({id: id}) }
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