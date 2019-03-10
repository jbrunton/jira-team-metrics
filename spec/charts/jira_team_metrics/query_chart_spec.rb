require 'rails_helper'

describe JiraTeamMetrics::QueryChart do
  let(:board) { create(:board) }
  let(:date) { Date.parse('2018-01-01') }
  let(:report_params) do
    JiraTeamMetrics::ReportParams.new(board, {
      date_range: JiraTeamMetrics::DateRange.new(date, date + 35),
      query: "select key, status from scope() where status = 'Done'"
    })
  end

  describe "#data_table" do
    context "when @params = 'Daily'" do
      it "returns a table with rows matching the query" do
        board = create(:board)
        issue1 = create(:issue, board: board, status: 'Done', started_time: date, completed_time: date + 1)
        issue2 = create(:issue, board: board, status: 'Done', started_time: date + 2, completed_time: date + 3)
        create(:issue, board: board)
        create(:issue, board: board)

        data_table = JiraTeamMetrics::QueryChart.new(board, report_params).data_table

        expect(data_table).to eq(JiraTeamMetrics::DataTable.new(
          ['key', 'status'],
          [
            [issue1.key, 'Done'],
            [issue2.key, 'Done']
          ]
        ))
      end
    end
  end
end
