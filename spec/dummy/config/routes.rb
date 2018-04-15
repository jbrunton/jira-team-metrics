Rails.application.routes.draw do
  mount JiraTeamMetrics::Engine => "/metrics"
end
