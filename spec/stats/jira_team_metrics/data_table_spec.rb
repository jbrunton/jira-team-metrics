require 'rails_helper'

RSpec.describe JiraTeamMetrics::DataTable do
  let(:columns) { ['issue_key', 'issue_type'] }

  let(:rows) {[
    ['DEV-100', 'Story'],
    ['DEV-101', 'Bug'],
    ['DEV-102', 'Story']
  ]}

  describe "#initialize" do
    it "initializes the rows and columns" do
      data_table = JiraTeamMetrics::DataTable.new(columns, rows)
      expect(data_table.columns).to eq(columns)
      expect(data_table.rows).to eq(rows)
    end
  end

  describe "#group_by" do
    it "aggregates rows by the given block" do
      data_table = JiraTeamMetrics::DataTable.new(columns, rows)
      grouped_data = data_table.group_by('issue_type', :count, of: 'issue_key', as: 'Count')
      expect(grouped_data.columns).to eq(['issue_type', 'Count'])
      expect(grouped_data.rows).to eq([
        ['Story', 2],
        ['Bug', 1]
      ])
    end
  end
end