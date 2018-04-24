class JiraTeamMetrics::SyncBoardChannel < JiraTeamMetrics::Channel
  def subscribed
    stream_for JiraTeamMetrics::Board.find_by(jira_id: params[:id])
  end
end