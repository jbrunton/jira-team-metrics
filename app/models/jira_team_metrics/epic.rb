class JiraTeamMetrics::Epic < Draper::Decorator
  delegate_all

  def percent_done
    total_issues = issues(recursive: true)
    completed_issues = total_issues.select{ |issue| issue.completed? }
    completed_issues.count * 100.0 / total_issues.count
  end

  def scope
    @scope ||= object.issues(recursive: true)
  end

  def completed_scope(date_range = nil)
    if date_range.nil?
      @completed_scope ||= scope.select{ |issue| issue.completed? }
    else
      completed_scope.select{ |issue| date_range.contains?(issue.completed_time) }
    end
  end

  def in_progress_scope
    @in_progress_scope ||= scope.select{ |issue| issue.in_progress? }
  end

  def remaining_scope
    @remaining_scope ||= scope.select{ |issue| !issue.completed? }
  end

  def throughput(rolling_window)
    if started_time
      window_end = completed_time || DateTime.now
      window_start = rolling_window.nil? ? started_time : window_end - rolling_window
      date_range = JiraTeamMetrics::DateRange.new(window_start, window_end)
      completed_scope(date_range).count.to_f / (window_end - window_start)
    else
      0
    end
  end

  def forecast(rolling_window)
    if completed?
      completed_time
    else
      throughput = self.throughput(rolling_window)
      DateTime.now + remaining_scope.count / throughput if throughput > 0
    end
  end
end