class JiraTeamMetrics::DataTableBuilder
  def data(data)
    @data = data
    self
  end

  def pick(*methods)
    @methods = methods
    self
  end

  def build
    JiraTeamMetrics::DataTable.new(
      @methods.map { |m| m.to_s },
      @data.map do |item|
        @methods.map { |m| item.send(m) }
      end
    )
  end
end