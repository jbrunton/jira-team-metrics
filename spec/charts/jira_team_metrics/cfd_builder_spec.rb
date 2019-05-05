require 'rails_helper'

describe JiraTeamMetrics::CfdBuilder do
  let(:from_date) { DateTime.new(2019, 1, 1) }
  let(:to_date) { DateTime.new(2019, 1, 5) }
  let(:date_range) { JiraTeamMetrics::DateRange.new(from_date, to_date) }

  let(:board) { create(:board) }

  let(:issue1) { create(:issue, issue_created: from_date, started_time: from_date + 0.5, completed_time: from_date + 1.5) }
  let(:issue2) { create(:issue, issue_created: from_date + 0.5, started_time: from_date + 0.5, completed_time: from_date + 2.5) }
  let(:issue3) { create(:issue, issue_created: from_date + 0.5, started_time: from_date + 1.5) }

  it "builds a CFD data table" do
    builder = JiraTeamMetrics::CfdBuilder.new(date_range, [issue1, issue2, issue3])

    data_table = builder.build.data_table

    expect(data_table.columns).to eq(['Date', 'Total', 'Tooltip', 'Done', 'In Progress', 'To Do'])
    expect(data_table.rows).to eq([
      ['Date(2019, 0, 1, 0, 0)', 0, 1, 0, 0, 1],
      ['Date(2019, 0, 2, 0, 0)', 0, 3, 0, 2, 1],
      ['Date(2019, 0, 3, 0, 0)', 0, 3, 1, 2, 0],
      ['Date(2019, 0, 4, 0, 0)', 0, 3, 2, 1, 0]
    ])
  end

  it "correctly handles issues that are closed without being started" do
    issue = create(:issue, issue_created: from_date + 0.5, completed_time: from_date + 1.5)
    builder = JiraTeamMetrics::CfdBuilder.new(date_range, [issue])

    data_table = builder.build.data_table

    expect(data_table.columns).to eq(['Date', 'Total', 'Tooltip', 'Done', 'In Progress', 'To Do'])
    expect(data_table.rows).to eq([
      ['Date(2019, 0, 1, 0, 0)', 0, 0, 0, 0, 0],
      ['Date(2019, 0, 2, 0, 0)', 0, 1, 0, 0, 1],
      ['Date(2019, 0, 3, 0, 0)', 0, 1, 1, 0, 0],
      ['Date(2019, 0, 4, 0, 0)', 0, 1, 1, 0, 0]
    ])
  end
end
