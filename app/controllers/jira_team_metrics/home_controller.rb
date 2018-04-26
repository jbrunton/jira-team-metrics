class JiraTeamMetrics::HomeController < JiraTeamMetrics::ApplicationController
  def index
    redirect_to domain_path
  end
end
