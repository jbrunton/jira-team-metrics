class JiraTeamMetrics::EvalContext
  attr_reader :issues

  def initialize(issues)
    @issues = issues
  end
end