module JiraTeamMetrics::DescriptiveScopeStatistics
  def issues_per_epic
    scope.count.to_f / epics.count
  end

  def percent_completed
    (100.0 * completed_scope.count) / scope.count
  end

  def started_date
    # TODO: trunc to date
    @started_date ||= scope.map{ |issue| issue.started_time }.compact.min || Time.now
  end

  def second_percentile_started_date
    return started_date if completed_scope.count < 10

    @second_percentile_started_date ||= begin
      completion_times = completed_scope.map{ |issue| issue.completed_time }.sort
      percentile_index = (completed_scope.count.to_f / 100.0).round + 1
      completion_times[percentile_index]
    end
  end

  def duration_excl_outliers
    if completed_scope.count >= 10
      completion_times = completed_scope.map{ |issue| issue.completed_time }.sort
      fifth_percentile_index = (completed_scope.count.to_f / 100.0 * 5.0).round
      ninetyfith_percentile_index = (completed_scope.count) - fifth_percentile_index
      (completion_times[ninetyfith_percentile_index - 1] - completion_times[fifth_percentile_index + 1]) / 1.day
    else
      (completed_date - started_date) / 1.day
    end
  end

  # TODO: rename this to last_completed_issue_date or something
  def completed_date
    # TODO: trunc to date
    @completed_date ||= scope.map{ |issue| issue.completed_time }.compact.max || Time.now + 90.days
  end

  def completed_scope_between(from_date, to_date)
    completed_scope.select{ |issue| from_date <= issue.completed_time && issue.completed_time <= to_date }
  end

  def completion_rate_between(from_date, to_date)
    completed_scope_between(from_date, to_date).count.to_f / ((to_date - from_date) / 1.day)
  end

  def rolling_completed_issues(days)
    @rolling_completed_issues ||= {}
    @rolling_completed_issues[days] ||= completed_scope_between(Time.now - days.days, Time.now)
  end

  def rolling_completion_rate(days)
    @rolling_completion_date ||= {}
    @rolling_completion_date[days] ||=
      rolling_completed_issues(days).count.to_f / days
  end

  def completion_rate
    return 0 if completed_scope.empty?
    @completion_rate ||= completed_scope_between(started_date, completed_date).count.to_f /
      ((completed_date - started_date) / 1.day)
  end

  def rolling_forecast_completion_date(days)
    completion_rate = rolling_completion_rate(days)
    if completion_rate == 0
      nil
    else
      Time.now + (remaining_scope.count.to_f / completion_rate).days
    end
  end
end