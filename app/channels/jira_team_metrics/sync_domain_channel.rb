class JiraTeamMetrics::SyncDomainChannel < JiraTeamMetrics::ApplicationCable::Channel
  def subscribed
    stream_for Domain.find(params[:id])
  end
end