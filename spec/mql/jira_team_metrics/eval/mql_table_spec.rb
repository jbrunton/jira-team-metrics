require 'rails_helper'

RSpec.describe JiraTeamMetrics::Eval::MqlTable do
  let(:table) do
    columns = ['Name', 'Age']
    rows = [['Alice', 30], ['Bob', 28]]
    JiraTeamMetrics::Eval::MqlTable.new(columns, rows)
  end

  context "#select_field" do
    it "returns the value of the given field" do
      expect(table.select_field('Name', 0)).to eq('Alice')
      expect(table.select_field('Age', 1)).to eq(28)
    end
  end

  context "#select_rows" do
    it "returns a table with selected rows" do
      results = table.select_rows do |row_index|
        table.select_field('Name', row_index) == 'Alice'
      end
      expect(results.columns).to eq(['Name', 'Age'])
      expect(results.rows).to eq([['Alice', 30]])
    end
  end
end