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
    @data_table = JiraTeamMetrics::DataTable.new([
      'Date', 'Total', 'Tooltip', 'Done', 'In Progress', 'To Do'
    ], [])

    dates = date_range.to_a

    dates.each do |date|
      data_table.add_row [date_as_string(date), 0, 0, 0, 0, 0]
    end

    scope.each do |issue|
      completed_time = issue.completed_time || date_range.end_date + 1
      started_time = issue.started_time || completed_time
      created_time = issue.issue_created

      dates.each_with_index do |date, index|
        if created_time <= date && date < started_time
          data_table.rows[index][5] += 1
        elsif started_time <= date && date < completed_time
          data_table.rows[index][4] += 1
        elsif completed_time <= date
          data_table.rows[index][3] += 1
        end
        data_table.rows[index][2] += 1 unless created_time > date
      end
    end
    self
  end
end
