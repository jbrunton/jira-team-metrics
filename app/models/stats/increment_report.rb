class IncrementReport
  attr_reader :issues
  attr_reader :completed_issues
  attr_reader :remaining_issues

  def initialize(issues)
    @issues = issues
  end

  def build
    issues_by_status_category = @issues.group_by{ |issue| issue.status_category }
    @completed_issues = issues_by_status_category['Done']
    @remaining_issues = issues_by_status_category['To Do'] + issues_by_status_category['In Progress']
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

  def cfd_data(from_date)
    data = [['Day', 'Done', 'In Progress', 'To Do']]
    dates = DateRange.new(from_date, Time.now).to_a
    dates.each_with_index do |date, index|
      row = [index]

      states = cfd_states_on(date)

      row << states['Done']
      row << states['In Progress']
      row << states['To Do']

      data << row
    end
    data
  end

  def cfd_states_on(date)
    to_do = 0
    in_progress = 0
    done = 0

    @issues.each do |issue|
      case issue.status_category_on(date)
        when 'To Do'
          to_do += 1
        when 'In Progress'
          in_progress += 1
        when 'Done'
          done += 1
      end
    end

    {
      'To Do' => to_do,
      'In Progress' => in_progress,
      'Done' => done
    }
  end
end