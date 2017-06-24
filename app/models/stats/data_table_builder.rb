class DataTableBuilder
  def initialize
    @cols = []
    @rows = []
  end

  def column(opts, values = nil)
    @cols << opts
    unless values.nil?
      values.each_with_index do |v, index|
        @rows[index] ||= []
        @rows[index] << {v: v}
      end
    end
    self
  end

  def number(opts, values = nil)
    column(opts.merge(type: 'number'), values)
  end

  def interval(opts, values = nil)
    number(opts.merge(role: 'interval'), values)
  end

  def build
    {
      cols: @cols,
      rows: @rows.map{ |values| {c: values} }
    }
  end
end