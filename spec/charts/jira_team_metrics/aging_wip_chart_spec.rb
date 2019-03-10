require 'rails_helper'

describe JiraTeamMetrics::ThroughputChart do
  let(:date) { DateTime.parse('2018-01-01') }
  let(:report_params) do
    JiraTeamMetrics::ReportParams.new({
      date_range: JiraTeamMetrics::DateRange.new(date - 30, date),
      hierarchy_level: 'Scope',
      step_interval: 'Weekly'
    })
  end

  before(:each) { travel_to date }

  describe "#data_table" do
    it "returns a table with percentiles" do
      board = create(:board)
      create(:issue, board: board, started_time: date - 4, completed_time: date - 1)
      create(:issue, board: board, started_time: date - 3, completed_time: date - 1)
      create(:issue, board: board, started_time: date - 2, completed_time: date - 1)

      wip1 = create(:issue, board: board, status: 'In Progress', started_time: date - 4)
      wip2 = create(:issue, board: board, status: 'In Progress', started_time: date - 2)
      wip3 = create(:issue, board: board, status: 'In Progress', started_time: date - 3)

      chart = JiraTeamMetrics::AgingWipChart.new(board, report_params)
      data_table = chart.data_table

      expect(data_table.columns).to eq(['key', 'summary', 'tooltip', 'started_time', 'now'])
      expect(data_table.rows).to eq([
        ['Percentiles', '85th', chart.render_percentile_tooltip(85), date - 2.7, date],
        ['Percentiles', '70th', chart.render_percentile_tooltip(70), date - 2.4, date],
        ['Percentiles', '50th', chart.render_percentile_tooltip(50), date - 2.0, date],
        [wip1.key, wip1.summary, chart.render_issue_tooltip(wip1, date), wip1.started_time, date],
        [wip3.key, wip3.summary, chart.render_issue_tooltip(wip3, date), wip3.started_time, date],
        [wip2.key, wip2.summary, chart.render_issue_tooltip(wip2, date), wip2.started_time, date]
      ])
    end
  end
end