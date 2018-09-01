class JiraTeamMetrics::StatusNotifier
  def initialize(model, status_title)
    @model = model
    @status_title = status_title
  end

  def notify_status(status)
    broadcast(
      status: status,
      in_progress: true
    )
  end

  def notify_complete
    broadcast(
      in_progress: false
    )
  end

  def notify_error(error, error_code = nil)
    message = {
      error: error,
      in_progress: false
    }
    message = message.merge(errorCode: error_code) unless error_code.nil?
    broadcast(message)
  end

  def notify_progress(status, progress)
    broadcast(
      status: status,
      in_progress: true,
      progress: progress
    )
  end

private
  def broadcast(message)
    message.merge!(statusTitle: @status_title) unless message[:status].nil?
    case
      when @model.is_a?(JiraTeamMetrics::Board)
        ActionCable.server.broadcast("sync_domain", message)
        ActionCable.server.broadcast("sync_board_#{@model.jira_id}", message)
      when @model.is_a?(JiraTeamMetrics::Domain)
        ActionCable.server.broadcast("sync_domain", message)
      else
        raise "Unexpected model type: #{@model.class}"
    end
  end
end