class JiraTeamMetrics::SyncDomainChannel < JiraTeamMetrics::Channel
  def subscribed
    stream_from "sync_domain"
  end
end