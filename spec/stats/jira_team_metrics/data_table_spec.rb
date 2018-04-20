require 'rails_helper'

RSpec.describe JiraTeamMetrics::DataTable do
  let(:columns) { ['issue_key', 'issue_type', 'developer', 'cycle_time'] }

  let(:rows) {[
    ['DEV-100', 'Story', 'Joe', 3],
    ['DEV-101', 'Bug', 'Anne', 2],
    ['DEV-102', 'Story', nil, nil],
    ['DEV-102', 'Story', 'Anne', 4]
  ]}

  describe "#initialize" do
    it "initializes the rows and columns" do
      data_table = JiraTeamMetrics::DataTable.new(columns, rows)
      expect(data_table.columns).to eq(columns)
      expect(data_table.rows).to eq(rows)
    end
  end

  describe "#group_by" do
    it "aggregates rows by the given column" do
      data_table = JiraTeamMetrics::DataTable.new(columns, rows)
      grouped_data = data_table.group_by('issue_type', :count, of: 'issue_key', as: 'Count')
      expect(grouped_data.columns).to eq(['issue_type', 'Count'])
      expect(grouped_data.rows).to eq([
        ['Story', 3],
        ['Bug', 1]
      ])
    end

    it "aggregates based on compacted values" do
      data_table = JiraTeamMetrics::DataTable.new(columns, rows)
      grouped_data = data_table.group_by('issue_type', :count, of: 'developer', as: 'Count')
      expect(grouped_data.columns).to eq(['issue_type', 'Count'])
      expect(grouped_data.rows).to eq([
        ['Story', 2],
        ['Bug', 1]
      ])
    end

    it "aggregates based on the given function" do
      data_table = JiraTeamMetrics::DataTable.new(columns, rows)
      grouped_data = data_table.group_by('issue_type', :sum, of: 'cycle_time', as: 'Sum')
      expect(grouped_data.columns).to eq(['issue_type', 'Sum'])
      expect(grouped_data.rows).to eq([
        ['Story', 7],
        ['Bug', 2]
      ])
    end
  end
end