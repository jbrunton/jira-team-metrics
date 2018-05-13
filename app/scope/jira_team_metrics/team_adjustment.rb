JiraTeamMetrics::TeamAdjustment = Struct.new(:adjustments) do
  def adjusted_epic_scope(trained_epic_scope)
    return epic_scope unless epic_scope.nil?
    return trained_epic_scope * epic_scope_factor unless epic_scope_factor.nil?
  end

  def adjusted_throughput(trained_throughput)
    return throughput unless throughput.nil?
    return trained_throughput * throughput_factor unless throughput_factor.nil?
  end

private
  def epic_scope
    adjustments['epic_scope']
  end

  def epic_scope_factor
    adjustments['epic_scope_factor']
  end

  def throughput
    adjustments['throughput']
  end

  def throughput_factor
    adjustments['throughput_factor']
  end
end