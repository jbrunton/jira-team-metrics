class JiraTeamMetrics::StatusNotifier
  def initialize(model, status_title)
    @model = model
    @status_title = status_title
  end

  def notify_status(status)
    message = build_message({
      status: status,
      in_progress: true
    })
    broadcast(message)
  end

  def notify_complete
    message = build_message(in_progress: false)
    case
      when @model.is_a?(JiraTeamMetrics::Board)
        if @model.domain.active?
          # if the domain is active, then we're only syncing a board, not the domain
          broadcast_to_domain(message)
        end
        broadcast_to_board(message)
      when @model.is_a?(JiraTeamMetrics::Domain)
        broadcast_to_domain(message)
      else
        raise "Unexpected model type: #{@model.class}"
    end
  end

  def notify_error(error, error_code = nil)
    message = build_message({
      error: error,
      in_progress: false
    }, error_code)
    broadcast(message)
  end

  def notify_progress(status, progress)
    message = build_message({
      status: status,
      in_progress: true,
      progress: progress
    })
    broadcast(message)
  end

private
  def broadcast(message)
    case
      when @model.is_a?(JiraTeamMetrics::Board)
        broadcast_to_domain(message)
        broadcast_to_board(message)
      when @model.is_a?(JiraTeamMetrics::Domain)
        broadcast_to_domain(message)
      else
        raise "Unexpected model type: #{@model.class}"
    end
  end

  def broadcast_to_board(message)
    ActionCable.server.broadcast("sync_board_#{@model.jira_id}", message)
  end

  def broadcast_to_domain(message)
    ActionCable.server.broadcast("sync_domain", message)
  end

  def build_message(message, error_code = nil)
    message = message.clone
    message.merge!(statusTitle: @status_title) unless message[:status].nil?
    message.merge!(errorCode: error_code) unless error_code.nil?
    message
  end
end