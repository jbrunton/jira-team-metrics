class JiraTeamMetrics::SyncBoardChannel < JiraTeamMetrics::Channel
  def subscribed
    stream_from "sync_board_#{params[:jira_id]}"
  end
end