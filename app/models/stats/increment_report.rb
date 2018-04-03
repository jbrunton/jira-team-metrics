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
      !increment.nil? && increment['issue']['key'] == @increment_key
    end
    @completed_issues = @issues.select{ |issue| issue.status_category == 'Done' }
    @remaining_issues = @issues.select{ |issue| issue.status_category != 'Done' }
    @increment = @issues.last.increment
    self
  end

  def name
    unless @increment.nil?
      "#{@increment['issue']['key']} &mdash; #{@increment['issue']['summary']}"
    end
  end

  def started_date
    @issues.map{ |issue| issue.started }.compact.min
  end

  def elapsed_time
    (Time.now - started_date) / (24 * 60 * 60)
  end

  def completion_rate
    completed_issues.count / elapsed_time
  end

  def rolling_completion_rate
    recently_completed_isssues = @completed_issues.select{ |issue| issue.completed >= Time.now - 14.days }
    recently_completed_isssues.count / 14.0
  end

  def forecast_completion_date
    Time.now + (remaining_issues.count / completion_rate).days
  end

  def rolling_forecast_completion_date
    Time.now + (remaining_issues.count / rolling_completion_rate).days
  end
end