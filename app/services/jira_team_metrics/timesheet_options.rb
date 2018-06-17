class JiraTeamMetrics::TimesheetOptions
  include JiraTeamMetrics::FormattingHelper

  attr_reader :month_periods
  attr_reader :selected_month_period
  attr_reader :timesheet_periods
  attr_reader :selected_timesheet_period

  def initialize(board, chart_params)
    @board = board
    @chart_params = chart_params
  end

  def build
    today = DateTime.now.beginning_of_day

    enumerate_month_periods(today)
    enumerate_timesheet_periods(today) unless @board.config.timesheets_config.nil?

    self
  end

private
  def enumerate_month_periods(today)
    month = today.beginning_of_month
    @month_periods = []
    6.times do
      date_range = JiraTeamMetrics::DateRange.new(month, month.next_month)
      label = month.strftime('%b %Y')
      @selected_month_period = label if selected_range?(date_range)
      @month_periods << [label, date_range]
      month = month.prev_month
    end
  end

  def enumerate_timesheet_periods(today)
    timesheets_config = @board.config.timesheets_config

    timesheet_start = today
    while timesheet_start.wday != timesheets_config.day_of_week
      timesheet_start = timesheet_start - 1
    end
    @timesheet_periods = []
    6.times do
      date_range = JiraTeamMetrics::DateRange.new(timesheet_start, timesheet_start + timesheets_config.duration)
      label = pretty_print_date_range(date_range)
      @selected_timesheet_period = label if selected_range?(date_range)
      @timesheet_periods << [label, date_range]
      timesheet_start = timesheet_start - timesheets_config.duration
    end
  end

  def selected_range?(date_range)
    @chart_params.date_range.start_date.to_date == date_range.start_date.to_date &&
      @chart_params.date_range.end_date.to_date == date_range.end_date.to_date
  end
end
