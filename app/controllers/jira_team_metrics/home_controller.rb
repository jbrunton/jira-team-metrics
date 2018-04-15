class JiraTeamMetrics::HomeController < JiraTeamMetrics::ApplicationController
  def index
    redirect_to '/domain'
  end
end
