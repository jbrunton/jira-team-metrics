class JiraTeamMetrics::HttpErrorHandler
  def initialize(notifier)
    @notifier = notifier
  end

  def invoke
    begin
      yield
    rescue Timeout::Error
      @notifier.notify_error('connection timed out')
      raise
    rescue Errno::EINVAL, Errno::ECONNRESET, EOFError, Net::HTTPBadResponse,
      Net::HTTPHeaderSyntaxError, Net::ProtocolError => e
      @notifier.notify_error(e.message, e.try(:response).try(:code))
      raise
    end
  end
end