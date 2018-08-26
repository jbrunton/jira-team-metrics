class JiraTeamMetrics::SyncBoardChannel < JiraTeamMetrics::Channel
  def subscribed
    stream_for JiraTeamMetrics::Board.find(params[:id])
  end
end