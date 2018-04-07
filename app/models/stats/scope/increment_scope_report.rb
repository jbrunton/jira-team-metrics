class IncrementScopeReport < TeamScopeReport
  include DescriptiveScopeStatistics

  attr_reader :issues
  attr_reader :epics
  attr_reader :scope
  attr_reader :completed_scope
  attr_reader :remaining_scope
  attr_reader :predicted_scope

  attr_reader :teams

  def initialize(increment)
    @increment = increment
  end

  def build

    self
  end
end