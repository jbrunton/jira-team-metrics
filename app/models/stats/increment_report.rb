class IncrementReport
  attr_reader :issues
  attr_reader :completed_issues
  attr_reader :remaining_issues

  def initialize(board, increment_key)
    @board = board
    @increment_key = increment_key
  end

  def build
    @issues = @board.issues.select do |issue|
      increment = issue.increment
      !increment.nil? &&
        increment['issue']['key'] == @increment_key &&
        issue.issue_type != 'Epic'
    end
    @completed_issues = @issues.select{ |issue| issue.status_category == 'Done' }
    @remaining_issues = @issues.select{ |issue| issue.status_category != 'Done' }
    @increment = @issues.last.increment
    self
  end

  def name
    unless @increment.nil?
      "#{@increment['issue']['key']} – #{@increment['issue']['summary']}"
    end
  end

  def started_date
    @issues.map{ |issue| issue.started }.compact.min
  end

  def elapsed_time
    (Time.now - started_date) / (24 * 60 * 60)
  end

  def rolling_time_span(days)
    [days, elapsed_time].min
  end

  def rolling_completed_issues(days)
    @completed_issues.select{ |issue|
      begin
        issue.completed >= Time.now - days.days
      rescue Exception => e
        byebug
      end}
  end

  def rolling_completion_rate(days)
    rolling_completed_issues(days).count / rolling_time_span(days)
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