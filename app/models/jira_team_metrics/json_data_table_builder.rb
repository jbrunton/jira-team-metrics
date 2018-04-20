class JiraTeamMetrics::JsonDataTableBuilder
  def initialize
    @cols = []
    @rows = []
  end

  def column(opts, values)
    @cols << opts
    values.each_with_index do |v, index|
      @rows[index] ||= []
      @rows[index] << {v: v}
    end
    self
  end

  def number(opts, values)
    column(opts.merge(type: 'number'), values)
  end

  def interval(opts, values)
    number(opts.merge(role: 'interval'), values)
  end

  def build
    {
      cols: @cols,
      rows: @rows.map{ |values| {c: values} }
    }
  end
end