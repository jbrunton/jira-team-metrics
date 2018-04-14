class SyncDomainChannel < ApplicationCable::Channel
  def subscribed
    stream_for JiraTeamMetrics::Domain.find(params[:id])
  end
end