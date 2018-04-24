class JiraTeamMetrics::SyncDomainChannel < JiraTeamMetrics::Channel
  def subscribed
    stream_for JiraTeamMetrics::Domain.find(params[:id])
  end
end