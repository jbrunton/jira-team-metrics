require 'rails_helper'

RSpec.describe JiraTeamMetrics::TimesheetOptions do
  let(:board) { create(:board) }
  let(:date_range) { JiraTeamMetrics::DateRange.new(DateTime.new(2001, 1, 1), DateTime.new(2001, 2, 1)) }
  let(:chart_options) { JiraTeamMetrics::ReportParams.new(board, { date_range: date_range}) }
  let(:config_string) do
    <<-SCHEMA
    timesheets:
      reporting_period:
        day_of_week: 6
        duration:
          days: 7
    SCHEMA
  end
  let(:board) { create(:board, config_string: config_string) }
  let(:timesheets_config) { board.config.timesheets }
  let(:timesheet_options) { JiraTeamMetrics::TimesheetOptions.new(chart_options, timesheets_config) }

  before(:each) { travel_to DateTime.new(2001, 1, 15) }

  describe "#build" do
    before(:each) { timesheet_options.build }

    it "enumerates month options" do
      expect(timesheet_options.month_periods).to eq([
        ['Jan 2001', JiraTeamMetrics::DateRange.new(DateTime.new(2001, 1,  1), DateTime.new(2001, 2,  1))],
        ['Dec 2000', JiraTeamMetrics::DateRange.new(DateTime.new(2000, 12, 1), DateTime.new(2001, 1,  1))],
        ['Nov 2000', JiraTeamMetrics::DateRange.new(DateTime.new(2000, 11, 1), DateTime.new(2000, 12, 1))],
        ['Oct 2000', JiraTeamMetrics::DateRange.new(DateTime.new(2000, 10, 1), DateTime.new(2000, 11, 1))],
        ['Sep 2000', JiraTeamMetrics::DateRange.new(DateTime.new(2000, 9,  1), DateTime.new(2000, 10, 1))],
        ['Aug 2000', JiraTeamMetrics::DateRange.new(DateTime.new(2000, 8,  1), DateTime.new(2000, 9,  1))]
      ])
    end

    it "sets the selected month" do
      expect(timesheet_options.selected_month_period).to eq('Jan 2001')
    end

    it "enumerates timesheet period options" do
      expect(timesheet_options.timesheet_periods).to eq([
        ['13 Jan - 20 Jan', JiraTeamMetrics::DateRange.new(DateTime.new(2001, 1,  13), DateTime.new(2001, 1,  20))],
        ['06 Jan - 13 Jan', JiraTeamMetrics::DateRange.new(DateTime.new(2001, 1,  6),  DateTime.new(2001, 1,  13))],
        ['30 Dec 2000 - 06 Jan', JiraTeamMetrics::DateRange.new(DateTime.new(2000, 12, 30), DateTime.new(2001, 1,  6))],
        ['23 Dec 2000 - 30 Dec 2000', JiraTeamMetrics::DateRange.new(DateTime.new(2000, 12, 23), DateTime.new(2000, 12, 30))],
        ['16 Dec 2000 - 23 Dec 2000', JiraTeamMetrics::DateRange.new(DateTime.new(2000, 12, 16), DateTime.new(2000, 12, 23))],
        ['09 Dec 2000 - 16 Dec 2000', JiraTeamMetrics::DateRange.new(DateTime.new(2000, 12, 9),  DateTime.new(2000, 12, 16))]
      ])
    end

    it "enumerates relative period options" do
      expect(timesheet_options.relative_periods).to eq([
        ['Last 7 days', JiraTeamMetrics::DateRange.new(DateTime.new(2001, 1,  8),    DateTime.new(2001, 1,  15))],
        ['Last 30 days', JiraTeamMetrics::DateRange.new(DateTime.new(2000, 12,  16), DateTime.new(2001, 1,  15))],
        ['Last 90 days', JiraTeamMetrics::DateRange.new(DateTime.new(2000, 10,  17), DateTime.new(2001, 1,  15))],
        ['Last 180 days', JiraTeamMetrics::DateRange.new(DateTime.new(2000, 7,  19), DateTime.new(2001, 1,  15))],
        ['Last 3 calendar months', JiraTeamMetrics::DateRange.new(DateTime.new(2000, 10, 1), DateTime.new(2001, 1,  1))],
        ['Last 6 calendar months', JiraTeamMetrics::DateRange.new(DateTime.new(2000, 7,  1), DateTime.new(2001, 1,  1))]
      ])
    end
  end
end
