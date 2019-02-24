class JiraTeamMetrics::TimesheetOptions
  include JiraTeamMetrics::FormattingHelper

  attr_reader :month_periods
  attr_reader :selected_month_period
  attr_reader :timesheet_periods
  attr_reader :selected_timesheet_period
  attr_reader :relative_periods
  attr_reader :selected_relative_period

  def initialize(report_params, timesheets_config)
    @report_params = report_params
    @timesheets_config = timesheets_config
  end

  def build
    today = DateTime.now.beginning_of_day

    enumerate_month_periods(today)
    enumerate_timesheet_periods(today) unless @timesheets_config.reporting_period.day_of_week.nil?
    enumerate_relative_periods(today)

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
    timesheet_start = today
    while timesheet_start.wday != @timesheets_config.reporting_period.day_of_week
      timesheet_start = timesheet_start - 1
    end
    @timesheet_periods = []
    6.times do
      date_range = JiraTeamMetrics::DateRange.new(timesheet_start, timesheet_start + @timesheets_config.reporting_period.duration.days)
      label = pretty_print_date_range(date_range)
      @selected_timesheet_period = label if selected_range?(date_range)
      @timesheet_periods << [label, date_range]
      timesheet_start = timesheet_start - @timesheets_config.reporting_period.duration.days
    end
  end

  def enumerate_relative_periods(today)
    start_of_month = today.at_beginning_of_month
    @relative_periods = [
      ['Last 7 days', JiraTeamMetrics::DateRange.new(today - 7, today)],
      ['Last 30 days', JiraTeamMetrics::DateRange.new(today - 30, today)],
      ['Last 90 days', JiraTeamMetrics::DateRange.new(today - 90, today)],
      ['Last 180 days', JiraTeamMetrics::DateRange.new(today - 180, today)],
      ['Last 3 calendar months', JiraTeamMetrics::DateRange.new(start_of_month - 3.months, start_of_month)],
      ['Last 6 calendar months', JiraTeamMetrics::DateRange.new(start_of_month - 6.months, start_of_month)]
    ]
    @relative_periods.each do |label, date_range|
      @selected_relative_period = label if selected_range?(date_range)
    end
  end

  def selected_range?(date_range)
    @report_params.date_range.start_date.to_date == date_range.start_date.to_date &&
      @report_params.date_range.end_date.to_date == date_range.end_date.to_date
  end
end
