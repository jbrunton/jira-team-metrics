module JiraTeamMetrics::EnvironmentHelper
  def readonly_mode?
    !!ENV['READONLY']
  end

  def env_credentials?
    !ENV['JIRA_USERNAME'].blank? && !ENV['JIRA_PASSWORD'].blank?
  end

  def env_credentials
    JiraTeamMetrics::Credentials.new(
      username: ENV['JIRA_USERNAME'],
      password: ENV['JIRA_PASSWORD']
    ) if env_credentials?
  end
end