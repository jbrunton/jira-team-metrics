class JiraTeamMetrics::ReportsController < JiraTeamMetrics::ApplicationController
  before_action :set_domain
  before_action :set_board

  include JiraTeamMetrics::FormattingHelper

  def timesheets
    now = DateTime.now.beginning_of_day

    month = this_month = now.beginning_of_month
    @month_periods = [
      ['This Month', JiraTeamMetrics::DateRange.new(this_month, now)]
    ]
    while month > this_month - 180
      month = month.prev_month
      @month_periods << [month.strftime('%b %Y'),
        JiraTeamMetrics::DateRange.new(month, month.next_month)]
    end

    timesheets_config = @board.config.timesheets_config
    unless timesheets_config.nil?
      timesheet_start = now
      while timesheet_start.day != timesheets_config.day_of_week
        timesheet_start = timesheet_start - 1
      end
      @timesheet_periods = [
        ['Current Period', JiraTeamMetrics::DateRange.new(timesheet_start, timesheet_start + timesheets_config.duration)]
      ]
      5.times do
        timesheet_start = timesheet_start - timesheets_config.duration
        timesheet_range = JiraTeamMetrics::DateRange.new(timesheet_start, timesheet_start + timesheets_config.duration)
        @timesheet_periods << [pretty_print_date_range(timesheet_range), timesheet_range]
      end
    end
  end

  def throughput
  end

  def deliveries
    @increments = @board.increments
  end

  def delivery
    @board = JiraTeamMetrics::Board.find_by(jira_id: @board.jira_id)
    @increment = @board.issues.find_by(key: params[:issue_key])
  end

  def scatterplot
  end

  def aging_wip
  end

  def delivery_scope
    @team = params[:team]
    @increment = @board.issues.find_by(key: params[:issue_key])

    @report = JiraTeamMetrics::TeamScopeReport.for(@increment, @team)
    @issues_by_epic = @report.scope
      .group_by{ |issue| issue.epic }
      .sort_by{ |epic, _| epic.nil? ? 1 : 0 }
      .to_h
  end

  def delivery_throughput
    @team = params[:team]
    @increment = @board.issues.find_by(key: params[:issue_key])
  end

  def increment_report
    @increment_report ||= JiraTeamMetrics::IncrementScopeReport.new(@increment).build
  end

  helper_method :cfd_data
  helper_method :team_dashboard_data
  helper_method :increment_report

  def cfd_data(cfd_type)
    JiraTeamMetrics::ReportFragment.fetch_contents(@increment.board, report_key, "cfd:#{cfd_type}")
  end

  def team_dashboard_data
    JiraTeamMetrics::ReportFragment.fetch_contents(@increment.board, report_key, "team_dashboard")
  end

  def report_key
    "delivery/#{@increment.key}"
  end
end