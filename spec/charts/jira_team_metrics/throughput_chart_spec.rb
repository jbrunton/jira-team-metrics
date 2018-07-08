require 'rails_helper'

describe JiraTeamMetrics::ThroughputChart do
  let(:date) { Date.parse('2018-01-01') }
  let(:chart_params) do
    JiraTeamMetrics::ChartParams.new({
      date_range: JiraTeamMetrics::DateRange.new(date, date + 35),
      hierarchy_level: 'Scope',
      step_interval: 'Weekly'
    })
  end

  describe "#data_table" do
    context "when @params = 'Daily'" do
      it "returns a table with a moving weekly average" do
        board = create(:board)
        create(:issue, board: board, started_time: date, completed_time: date + 1)
        create(:issue, board: board, started_time: date + 2, completed_time: date + 3)
        create(:issue, board: board, started_time: date + 7, completed_time: date + 8)
        create(:issue, board: board, started_time: date + 21, completed_time: date + 22)

        data_table = JiraTeamMetrics::ThroughputChart.new(board, chart_params).data_table

        expect(data_table).to eq(JiraTeamMetrics::DataTable.new(
          ['completed_time', 'Count', 'Rolling Avg / Week (prev 4 weeks)'],
          [
            [date,      2, nil],
            [date + 7,  1, nil],
            [date + 14, 0, nil],
            [date + 21, 1, 1.0],
            [date + 28, 0, 0.5]
          ]
        ))
      end
    end
  end
end