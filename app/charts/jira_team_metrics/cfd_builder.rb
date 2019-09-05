class JiraTeamMetrics::CfdBuilder
  include JiraTeamMetrics::ChartsHelper

  attr_reader :date_range
  attr_reader :scope
  attr_reader :data_table

  def initialize(date_range, scope)
    @date_range = date_range
    @scope = scope
  end

  def build
    init_table
    scope.each { |issue| add_issue(issue) }
    self
  end

private
  CFD_COLUMNS = ['Date', 'Total', 'Tooltip', 'Done', 'In Progress', 'To Do']

  def init_table
    @dates = date_range.to_a
    @data_table = JiraTeamMetrics::DataTable.new(CFD_COLUMNS, [])
    @dates.each do |date|
      data_table.add_row [date_as_string(date), 0, 0, 0, 0, 0]
    end
  end

  def add_issue(issue)
    completed_time = issue.completed_time || date_range.end_date + 1
    started_time = issue.started_time || completed_time
    created_time = issue.issue_created

    @dates.each_with_index do |date, index|
      count_issue(date, index, created_time, started_time, completed_time)
    end
  end

  def count_issue(date, date_index, created_time, started_time, completed_time)
    if created_time <= date && date < started_time
      data_table.rows[date_index][5] += 1
    elsif started_time <= date && date < completed_time
      data_table.rows[date_index][4] += 1
    elsif completed_time <= date
      data_table.rows[date_index][3] += 1
    end
    data_table.rows[date_index][2] += 1 unless created_time > date
  end
end
