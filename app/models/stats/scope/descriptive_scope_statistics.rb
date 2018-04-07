module DescriptiveScopeStatistics
  def issues_per_epic
    scope.count.to_f / epics.count
  end

  def percent_completed
    (100.0 * completed_scope.count) / scope.count
  end

  def started_date
    scope.map{ |issue| issue.started_time }.compact.min
  end

  def rolling_completed_issues(days)
    completed_scope.select{ |issue| issue.completed_time >= Time.now - days.days }
  end

  def rolling_completion_rate(days)
    rolling_completed_issues(days).count.to_f / days
  end

  def rolling_forecast_completion_date(days)
    completion_rate = rolling_completion_rate(days)
    if completion_rate == 0
      nil
    else
      Time.now + (remaining_scope.count / completion_rate).days
    end
  end
end