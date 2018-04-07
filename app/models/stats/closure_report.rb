class ClosureReport
  attr_reader :issues
  attr_reader :epics
  attr_reader :scope
  attr_reader :completed_scope
  attr_reader :remaining_scope

  def initialize(issues)
    @issues = issues
  end

  def build
    @epics = issues.select{ |issue| issue.issue_type == 'Epic' }
    @scope = issues.select{ |issue| issue.issue_type != 'Epic' }
    issues_by_status_category = @scope.group_by{ |issue| issue.status_category }
    @completed_scope = issues_by_status_category['Done'] || []
    @remaining_scope = (issues_by_status_category['To Do'] || []) + (issues_by_status_category['In Progress'] || [])
    self
  end

  def percent_completed
    (100.0 * completed_scope.count) / scope.count
  end

  def started_date
    issues.map{ |issue| issue.started_time }.compact.min
  end

  def elapsed_time
    # TODO: should be taken to be the start time of the increment, not the team
    (Time.now - started_date) / (24 * 60 * 60)
  end

  def rolling_time_span(days)
    [days, elapsed_time].min
  end

  def rolling_completed_issues(days)
    completed_scope.select{ |issue| issue.completed_time >= Time.now - days.days }
  end

  def rolling_completion_rate(days)
    rolling_completed_issues(days).count.to_f / rolling_time_span(days)
  end

  def rolling_forecast_completion_date(days)
    completion_rate = rolling_completion_rate(days)
    if completion_rate == 0
      nil
    else
      Time.now + (remaining_scope.count / completion_rate).days
    end
  end

  def cfd_data(from_date)
    data = [['Day', 'Done', 'In Progress', 'To Do']]
    dates = DateRange.new(from_date, Time.now).to_a
    dates.each_with_index do |date, index|
      data << cfd_row_for(date).to_array(index)
    end
    data
  end

  def cfd_row_for(date)
    row = CfdRow.new(0, 0, 0)

    issues.each do |issue|
      case issue.status_category_on(date)
        when 'To Do'
          row.to_do += 1
        when 'In Progress'
          row.in_progress += 1
        when 'Done'
          row.done += 1
      end
    end

    row
  end

  CfdRow = Struct.new(:to_do, :in_progress, :done) do
    def to_array(index)
      [index, done, in_progress, to_do]
    end
  end
end