require 'rails_helper'

describe JiraTeamMetrics::ThroughputChart do
  let(:board) { create(:board) }
  let(:date) { Date.parse('2018-01-01') }
  let(:report_params) do
    JiraTeamMetrics::ReportParams.new(board, {
      date_range: JiraTeamMetrics::DateRange.new(date, date + 35),
      hierarchy_level: 'Scope',
      step_interval: 'Weekly'
    })
  end

  describe "#data_table" do
    context "when @params = 'Daily'" do
      it "returns a table with percentiles" do
        board = create(:board)
        create(:issue, board: board, started_time: date, completed_time: date + 1)
        create(:issue, board: board, started_time: date + 2, completed_time: date + 3)
        create(:issue, board: board, started_time: date + 7, completed_time: date + 8)
        create(:issue, board: board, started_time: date + 21, completed_time: date + 22)
        create(:issue, board: board, started_time: date + 22, completed_time: date + 23)

        data_table = JiraTeamMetrics::ThroughputChart.new(board, report_params).data_table

        expect(data_table).to eq(JiraTeamMetrics::DataTable.new(
          ['completed_time', 'Count', '75th percentile', '50th percentile', '25th percentile'],
          [
            [date,        2, nil, nil, nil],
            [date + 7,    1, nil, nil, nil],
            [date + 14,   0, nil, nil, nil],
            [date + 21,   2, nil, nil, nil],
            [date + 28,   0, nil, nil, nil],
            [date,      nil, 2.0, 1.0, 0.0],
            [date + 28, nil, 2.0, 1.0, 0.0]
          ]
        ))
      end
    end
  end
end