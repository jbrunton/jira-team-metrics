class JiraTeamMetrics::Forecaster
  attr_reader :scope

  def initialize(scope)
    @scope = scope
  end

  def percent_done
    @percent_done ||= completed_scope.count * 100.0 / scope.count
  end

  def completed_scope(date_range = nil)
    if date_range.nil?
      @completed_scope ||= scope.select{ |issue| issue.completed? }
    else
      completed_scope.select{ |issue| date_range.contains?(issue.completed_time) }
    end
  end

  def completed?
    @completed ||= remaining_scope.empty?
  end

  def started_time
    scope.map{ |issue| issue.started_time }.compact.min
  end

  def completed_time
    scope.map{ |issue| issue.completed_time }.max if completed?
  end

  def in_progress_scope
    @in_progress_scope ||= scope.select{ |issue| issue.in_progress? }
  end

  def remaining_scope
    @remaining_scope ||= scope.select{ |issue| !issue.completed? }
  end

  def throughput(rolling_window)
    (@throughput ||= {})[rolling_window] ||= begin
      if started_time
        date_range = window_range(rolling_window)
        completed_scope(date_range).count.to_f / (date_range.end_date - date_range.start_date)
      else
        0
      end
    end
  end

  def forecast(rolling_window)
    (@forecasts ||= {})[rolling_window] ||= begin
      if completed?
        completed_time
      else
        throughput = self.throughput(rolling_window)
        DateTime.now + remaining_scope.count / throughput if throughput > 0
      end
    end
  end

private
  def window_range(rolling_window)
    window_end = completed_time || DateTime.now
    window_start = rolling_window.nil? ? started_time : window_end - rolling_window
    JiraTeamMetrics::DateRange.new(window_start, window_end)
  end
end