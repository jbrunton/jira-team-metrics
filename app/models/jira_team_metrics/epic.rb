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

  def completed_scope
    @completed_scope ||= scope.select{ |issue| issue.completed? }
  end

  def in_progress_scope
    @in_progress_scope ||= scope.select{ |issue| issue.in_progress? }
  end

  def remaining_scope
    @remaining_scope ||= scope.select{ |issue| !issue.completed? }
  end

  def throughput
    @throughput ||= begin
      if started_time
        completed_scope.count.to_f / (completed_time || DateTime.now - started_time)
      else
        0
      end
    end
  end

  def forecast
    @forecast ||= begin
      if completed?
        completed_time
      else
        DateTime.now + remaining_scope.count / throughput if throughput > 0
      end
    end
  end
end