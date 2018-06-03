module JiraTeamMetrics::EnvironmentHelper
  def readonly?
    !!ENV['READONLY']
  end
end