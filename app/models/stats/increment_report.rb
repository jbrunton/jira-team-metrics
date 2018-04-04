class IncrementReport
  attr_reader :issues
  attr_reader :completed_issues
  attr_reader :remaining_issues

  def initialize(issues)
    @issues = issues
  end

  def build
    @completed_issues = @issues.select{ |issue| issue.status_category == 'Done' }
    @remaining_issues = @issues.select{ |issue| issue.status_category != 'Done' }
    self
  end

  def started_date
    @issues.map{ |issue| issue.started_time }.compact.min
  end

  def elapsed_time
    (Time.now - started_date) / (24 * 60 * 60)
  end

  def rolling_time_span(days)
    [days, elapsed_time].min
  end

  def rolling_completed_issues(days)
    @completed_issues.select{ |issue| issue.completed_time >= Time.now - days.days }
  end

  def rolling_completion_rate(days)
    rolling_completed_issues(days).count.to_f / rolling_time_span(days)
  end

  def rolling_forecast_completion_date(days)
    completion_rate = rolling_completion_rate(days)
    if completion_rate == 0
      nil
    else
      Time.now + (remaining_issues.count / completion_rate).days
    end
  end
end