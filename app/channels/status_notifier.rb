class StatusNotifier
  def initialize(channel, object)
    @channel = channel
    @object = object
  end

  def notify_status(status)
    @channel.broadcast_to(
      @object,
      status: status,
      in_progress: true
    )
  end

  def notify_complete
    @channel.broadcast_to(
      @object,
      in_progress: false
    )
  end

  def notify_error(error, error_code)
    @channel.broadcast_to(
      @object,
      error: error,
      errorCode: error_code,
      in_progress: false
    )
  end

  def notify_progress(status, progress)
    @channel.broadcast_to(
      @object,
      status: status,
      in_progress: true,
      progress: progress
    )
  end
end