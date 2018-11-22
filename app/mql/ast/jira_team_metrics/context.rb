class JiraTeamMetrics::Context
  attr_reader :issues

  def initialize(issues)
    @issues = issues
  end
end