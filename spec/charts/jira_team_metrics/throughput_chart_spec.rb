require 'rails_helper'

describe JiraTeamMetrics::ThroughputChart do
  let(:date) { Date.parse('2018-01-01') }
  let(:report_params) do
    JiraTeamMetrics::ReportParams.new({
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

        data_table = JiraTeamMetrics::ThroughputChart.new(board, report_params)
          .data_table
          .map('30th percentile') { |it| it.try(:round, 2) }

        expect(data_table).to eq(JiraTeamMetrics::DataTable.new(
          ['completed_time', 'Count', '70th percentile', '50th percentile', '30th percentile'],
          [
            [date,        2, nil, nil, nil],
            [date + 7,    1, nil, nil, nil],
            [date + 14,   0, nil, nil, nil],
            [date + 21,   1, nil, nil, nil],
            [date + 28,   0, nil, nil, nil],
            [date,      nil, 1.0, 1.0, 0.2],
            [date + 28, nil, 1.0, 1.0, 0.2]
          ]
        ))
      end
    end
  end
end