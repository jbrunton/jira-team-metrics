JiraTeamMetrics::TeamAdjustment = Struct.new(:adjustments) do
  def adjusted_epic_scope(trained_epic_scope)
    if epic_scope.nil?
      trained_epic_scope * epic_scope_factor
    else
      epic_scope
    end
  end

  def adjusted_throughput(trained_throughput)
    if throughput.nil?
      trained_throughput * throughput_factor
    else
      throughput
    end
  end

private
  def epic_scope
    adjustments['epic_scope']
  end

  def epic_scope_factor
    adjustments['epic_scope_factor'] || 1.0
  end

  def throughput
    adjustments['throughput']
  end

  def throughput_factor
    adjustments['throughput_factor'] || 1.0
  end
end