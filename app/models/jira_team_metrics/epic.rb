class JiraTeamMetrics::Epic < Draper::Decorator
  delegate_all

  def percent_done
    unless is_scope?
      total_issues = issues(recursive: true)
      completed_issues = total_issues.select{ |issue| issue.completed? }
      completed_issues.count * 100.0 / total_issues.count
    end
  end

  def scope
    @scope ||= object.issues(recursive: true)
  end

  def completed_scope
    @completed_scope ||= scope.select{ |issue| issue.completed? }
  end

  def in_progress_scope
    @in_progress_scope ||= scope.select{ |issue| issue.in_progress? }
  end

  def remaining_scope
    @remaining_scope ||= scope.select{ |issue| issue.completed? }
  end

  def throughput
    completed_scope.count.to_f / (completed_time || DateTime.now - started_time)
  end

  def forecast
    started_time + remaining_scope.count / throughput
  end
end