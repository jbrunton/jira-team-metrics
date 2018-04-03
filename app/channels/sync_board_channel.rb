class SyncBoardChannel < ApplicationCable::Channel
  def subscribed
    stream_for Board.find_by(jira_id: params[:id])
  end
end