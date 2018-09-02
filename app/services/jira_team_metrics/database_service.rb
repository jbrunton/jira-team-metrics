class JiraTeamMetrics::DatabaseService
  # Run this method at startup, in case the app crashed mid-sync
  def prepare_database
    JiraTeamMetrics::Domain.update_all(syncing: false)
  end
end