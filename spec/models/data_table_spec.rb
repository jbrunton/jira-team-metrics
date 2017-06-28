require 'rails_helper'

RSpec.describe DataTable do
  HEADER = DataTable::Header.new(['Mean', 'StdDev'])
  ROW = DataTable::Row.new([1, 2], nil)

  it "initializes the rows" do
    table = DataTable.new([ROW])
    expect(table.rows).to eq([ROW])
  end

  describe "#column" do
    it "returns the row data in the given column" do
      table = DataTable.new([HEADER, ROW])
      expect(table.column(0)).to eq([1])
    end
  end
end