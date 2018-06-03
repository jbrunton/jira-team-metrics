module JiraTeamMetrics::EnvironmentHelper
  def readonly_mode?
    !!ENV['READONLY']
  end
end