class StatusNotifier
  def initialize(model, status_prefix = '')
    @model = model
    @status_prefix = status_prefix
  end

  def notify_status(status)
    broadcast(
      status: @status_prefix + status,
      in_progress: true
    )
  end

  def notify_complete
    broadcast(
      in_progress: false
    )
  end

  def notify_error(error, error_code)
    broadcast(
      error: error,
      errorCode: error_code,
      in_progress: false
    )
  end

  def notify_progress(status, progress)
    broadcast(
      status: @status_prefix + status,
      in_progress: true,
      progress: progress
    )
  end

private
  def broadcast(message)
    case
    when @model.is_a?(Board)
      SyncBoardChannel.broadcast_to(@model, message)
      SyncDomainChannel.broadcast_to(@model.domain, message)
    when @model.is_a?(Domain)
      SyncDomainChannel.broadcast_to(@model, message)
    else
      raise "Unexpected model type: #{@model.class}"
    end
  end
end