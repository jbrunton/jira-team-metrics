require 'rails_helper'

RSpec.describe JiraTeamMetrics::TimesheetOptions do
  let(:date_range) { JiraTeamMetrics::DateRange.new(DateTime.new(2001, 1, 1), DateTime.new(2001, 2, 1)) }
  let(:chart_options) { JiraTeamMetrics::ChartParams.new({ date_range: date_range}) }
  let(:timesheets_config) { JiraTeamMetrics::BoardConfig::TimesheetsConfig.new(6, 7, []) }
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
        ['30 Dec - 06 Jan', JiraTeamMetrics::DateRange.new(DateTime.new(2000, 12, 30), DateTime.new(2001, 1,  6))],
        ['23 Dec - 30 Dec', JiraTeamMetrics::DateRange.new(DateTime.new(2000, 12, 23), DateTime.new(2000, 12, 30))],
        ['16 Dec - 23 Dec', JiraTeamMetrics::DateRange.new(DateTime.new(2000, 12, 16), DateTime.new(2000, 12, 23))],
        ['09 Dec - 16 Dec', JiraTeamMetrics::DateRange.new(DateTime.new(2000, 12, 9),  DateTime.new(2000, 12, 16))]
      ])
    end

    it "enumerates relative period options" do
      expect(timesheet_options.relative_periods).to eq([
        ['Last 7 days', JiraTeamMetrics::DateRange.new(DateTime.new(2001, 1,  8),    DateTime.new(2001, 1,  15))],
        ['Last 30 days', JiraTeamMetrics::DateRange.new(DateTime.new(2000, 12,  16), DateTime.new(2001, 1,  15))],
        ['Last 90 days', JiraTeamMetrics::DateRange.new(DateTime.new(2000, 10,  17), DateTime.new(2001, 1,  15))],
        ['Last 180 days', JiraTeamMetrics::DateRange.new(DateTime.new(2000, 7,  19), DateTime.new(2001, 1,  15))]
      ])
    end
  end
end
