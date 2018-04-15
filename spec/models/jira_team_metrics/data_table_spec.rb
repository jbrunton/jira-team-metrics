require 'rails_helper'

RSpec.describe JiraTeamMetrics::DataTable do
  HEADER = JiraTeamMetrics::DataTable::Header.new(['Mean', 'StdDev'])
  ROW = JiraTeamMetrics::DataTable::Row.new([1, 2], nil)

  it "initializes the rows" do
    table = JiraTeamMetrics::DataTable.new([ROW])
    expect(table.rows).to eq([ROW])
  end

  describe "#column" do
    it "returns the row data in the given column" do
      table = JiraTeamMetrics::DataTable.new([HEADER, ROW])
      expect(table.column(0)).to eq([1])
    end
  end
end