require 'rails_helper'

describe JiraTeamMetrics::ThroughputChart do
  let(:board) { create(:board) }
  let(:date) { DateTime.parse('2018-01-01') }
  let(:report_params) do
    JiraTeamMetrics::ReportParams.new(board, {
      date_range: JiraTeamMetrics::DateRange.new(date - 30, date),
      hierarchy_level: 'Scope',
      step_interval: 'Weekly',
      aging_type: 'since started'
    })
  end

  before(:each) { travel_to date }

  describe "#data_table" do
    it "returns a table with percentiles" do
      21.times do |k|
        create(:issue, board: board, started_time: date - (k+2), completed_time: date - 1)
      end

      wip1 = create(:issue, board: board, status: 'In Progress', started_time: date - 19)
      wip2 = create(:issue, board: board, status: 'In Progress', started_time: date - 3)
      wip3 = create(:issue, board: board, status: 'In Progress', started_time: date - 16)

      chart = JiraTeamMetrics::AgingWipChart.new(board, report_params)
      data_table = chart.data_table

      expect(data_table.columns).to eq(['key', 'age', 'tooltip', 'style', 'annotation'])
      expect(data_table.rows).to eq([
        # completed ages from 1..21, 50th = 11, 75th = 15, 85th = 18
        ['85th', 18.0, chart.render_percentile_tooltip(85), 'color: #f44336', '85th percentile'],
        ['70th', 15.0, chart.render_percentile_tooltip(70), 'color: #ff9800', '70th percentile'],
        ['50th', 11.0, chart.render_percentile_tooltip(50), 'color: #03a9f4', '50th percentile'],
        [nil, nil, nil, nil, nil],
        [wip1.key, 19.0, chart.render_issue_tooltip(wip1, date), '#f44336', "#{wip1.key} - #{wip1.summary}"],
        [wip3.key, 16.0, chart.render_issue_tooltip(wip3, date), '#ff9800', "#{wip3.key} - #{wip3.summary}"],
        [wip2.key, 3.0, chart.render_issue_tooltip(wip2, date), '#03a9f4', "#{wip2.key} - #{wip2.summary}"]
      ])
    end
  end
end
