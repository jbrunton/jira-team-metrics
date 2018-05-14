JiraTeamMetrics::TeamAdjustment = Struct.new(:adjustments) do
  def adjusted_epic_scope(trained_epic_scope)
    epic_scope || begin
      trained_epic_scope * epic_scope_factor unless epic_scope_factor.nil?
    end
  end

  def adjusted_throughput(trained_throughput)
    throughput || begin
      trained_throughput * throughput_factor unless throughput_factor.nil?
    end
  end

private
  def epic_scope
    adjustments[:epic_scope]
  end

  def epic_scope_factor
    adjustments[:epic_scope_factor]
  end

  def throughput
    adjustments[:throughput]
  end

  def throughput_factor
    adjustments[:throughput_factor]
  end
end