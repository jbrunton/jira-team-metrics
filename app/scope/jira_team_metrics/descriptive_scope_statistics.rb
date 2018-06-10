module JiraTeamMetrics::DescriptiveScopeStatistics
  def epic_scope
    epics.count > 0 ? scope.count.to_f / epics.count : 0
  end

  def percent_completed
    (100.0 * completed_scope.count) / scope.count
  end

  def started_date
    # TODO: trunc to date
    @started_date ||= scope.map{ |issue| issue.started_time }.compact.min || DateTime.now
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
      (completion_times[ninetyfith_percentile_index - 1] - completion_times[fifth_percentile_index + 1]).to_f
    else
      (completed_date - started_date).to_f
    end
  end

  # TODO: rename this to last_completed_issue_date or something
  def completed_date
    # TODO: trunc to date
    @completed_date ||= scope.map{ |issue| issue.completed_time }.compact.max || DateTime.now + 90
  end

  def completed_scope_between(from_date, to_date)
    completed_scope.select{ |issue| from_date <= issue.completed_time && issue.completed_time <= to_date }
  end

  def throughput_between(from_date, to_date)
    completed_scope_between(from_date, to_date).count.to_f / (to_date - from_date).to_f
  end

  def rolling_completed_issues(days)
    @rolling_completed_issues ||= {}
    @rolling_completed_issues[days] ||= completed_scope_between(DateTime.now - days, DateTime.now)
  end

  def rolling_throughput(days)
    @rolling_completion_date ||= {}
    @rolling_completion_date[days] ||=
      rolling_completed_issues(days).count.to_f
  end

  def throughput
    return 0 if completed_scope.empty?
    @throughput ||= completed_scope_between(started_date, completed_date).count.to_f /
      (completed_date - started_date).to_f
  end

  def rolling_forecast_completion_date(days)
    throughput = rolling_throughput(days)
    if throughput == 0
      nil
    else
      DateTime.now + remaining_scope.count.to_f / throughput
    end
  end
end