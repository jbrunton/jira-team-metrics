require 'rails_helper'

RSpec.describe JiraTeamMetrics::ScopeCfdBuilder do
  let(:today) { DateTime.new(2018, 4, 8) }

  before(:each) { travel_to today }

  let(:issue1) { create(:issue, started_time: DateTime.new(2018, 4, 1), completed_time: DateTime.new(2018, 4, 3, 10, 30)) }
  let(:issue2) { create(:issue, started_time: DateTime.new(2018, 4, 2), completed_time: DateTime.new(2018, 4, 4, 10, 30)) }
  let(:issue3) { create(:issue, started_time: DateTime.new(2018, 4, 3)) }
  let(:issue4) { create(:issue, issue_created: DateTime.new(2018, 4, 1), status: 'Predicted') }

  def compare_data_tables(expected_table, actual_table)
    expect(actual_table.length).to eq(expected_table.length)
    actual_table.each_with_index do |actual_row, index|
      expected_row = expected_table[index]
      expect(actual_row).to eq(expected_row), lambda {
        "expected: #{expected_row.inspect}\n     got: #{actual_row.inspect}\n\n(mismatch at row index #{index})"
      }
    end
  end

  context "when no remaining scope is given" do
    let(:scope) { [issue1, issue2] }

    it "builds a CFD spanning the start and end dates with a buffer of 2 days" do
      builder = JiraTeamMetrics::ScopeCfdBuilder.new(scope, 7)
      data = builder.build
      compare_data_tables(data, [
        JiraTeamMetrics::ScopeCfdBuilder.build_header(false),
        ["Date(2018, 2, 30, 0, 0)", nil, 0, 0, 0, 0, 0],
        ["Date(2018, 2, 31, 0, 0)", nil, 0, 1, 0, 0, 1],
        ["Date(2018, 3, 1, 0, 0)", nil, 0, 2, 0, 0, 2],
        ["Date(2018, 3, 2, 0, 0)", nil, 0, 2, 0, 1, 1],
        ["Date(2018, 3, 3, 0, 0)", nil, 0, 2, 0, 2, 0],
        ["Date(2018, 3, 4, 0, 0)", nil, 0, 2, 1, 1, 0],
        ["Date(2018, 3, 5, 0, 0)", nil, 0, 2, 2, 0, 0],
        ["Date(2018, 3, 6, 0, 0)", nil, 0, 2, 2, 0, 0]])
    end
  end

  context "when some scope is remaining" do
    let(:scope) { [issue1, issue2, issue3] }

    it "builds a CFD with a predicted forecast" do
      builder = JiraTeamMetrics::ScopeCfdBuilder.new(scope, 7)
      data = builder.build
      compare_data_tables(data, [
        JiraTeamMetrics::ScopeCfdBuilder.build_header(false),
        ["Date(2018, 3, 1, 0, 0)", nil, 0, 2, 0, 0, 2],
        ["Date(2018, 3, 2, 0, 0)", nil, 0, 3, 0, 1, 2],
        ["Date(2018, 3, 3, 0, 0)", nil, 0, 3, 0, 2, 1],
        ["Date(2018, 3, 4, 0, 0)", nil, 0, 3, 1, 2, 0],
        ["Date(2018, 3, 5, 0, 0)", nil, 0, 3, 2, 1, 0],
        ["Date(2018, 3, 6, 0, 0)", nil, 0, 3, 2, 1, 0],
        ["Date(2018, 3, 7, 0, 0)", nil, 0, 3, 2, 1, 0],
        ["Date(2018, 3, 8, 0, 0)", nil, 0, 3, 2, 1, 0],
        ["Date(2018, 3, 9, 0, 0)", nil, 0, 3, 2, 1, 0],
        ["Date(2018, 3, 10, 0, 0)", nil, 0, 3, 2, 1, 0],
        ["Date(2018, 3, 11, 0, 0)", nil, 0, 3, 2, 1, 0],
        ["Date(2018, 3, 12, 0, 0)", nil, 0, 3, 3, 0, 0],
        ["Date(2018, 3, 13, 0, 0)", nil, 0, 3, 3, 0, 0],
        ["Date(2018, 3, 8)", "today", nil, nil, nil, nil, nil],
        ["Date(2018, 3, 11, 12, 0)", "forecast", nil, nil, nil, nil, nil]
      ])
    end
  end

  context "when some scope is predicted" do
    let(:scope) { [issue1, issue2, issue4] }

    it "builds a CFD with predicted scope" do
      builder = JiraTeamMetrics::ScopeCfdBuilder.new(scope, 7)
      data = builder.build
      compare_data_tables(data, [
        JiraTeamMetrics::ScopeCfdBuilder.build_header(true),
        ["Date(2018, 3, 1, 0, 0)", nil, 0, 3, 0, 0, 2, 1],
        ["Date(2018, 3, 2, 0, 0)", nil, 0, 3, 0, 1, 1, 1],
        ["Date(2018, 3, 3, 0, 0)", nil, 0, 3, 0, 2, 0, 1],
        ["Date(2018, 3, 4, 0, 0)", nil, 0, 3, 1, 1, 0, 1],
        ["Date(2018, 3, 5, 0, 0)", nil, 0, 3, 2, 0, 0, 1],
        ["Date(2018, 3, 6, 0, 0)", nil, 0, 3, 2, 0, 0, 1],
        ["Date(2018, 3, 7, 0, 0)", nil, 0, 3, 2, 0, 0, 1],
        ["Date(2018, 3, 8, 0, 0)", nil, 0, 3, 2, 0, 0, 1],
        ["Date(2018, 3, 9, 0, 0)", nil, 0, 3, 2, 0, 0, 1],
        ["Date(2018, 3, 10, 0, 0)", nil, 0, 3, 2, 0, 0, 1],
        ["Date(2018, 3, 11, 0, 0)", nil, 0, 3, 2, 0, 0, 1],
        ["Date(2018, 3, 12, 0, 0)", nil, 0, 3, 3, 0, 0, 0],
        ["Date(2018, 3, 13, 0, 0)", nil, 0, 3, 3, 0, 0, 0],
        ["Date(2018, 3, 8)", "today", nil, nil, nil, nil, nil, nil],
        ["Date(2018, 3, 11, 12, 0)", "forecast", nil, nil, nil, nil, nil, nil]
      ])
    end
  end
end