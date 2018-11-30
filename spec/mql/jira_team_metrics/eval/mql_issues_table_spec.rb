require 'rails_helper'

RSpec.describe JiraTeamMetrics::Eval::MqlIssuesTable do
  let(:bug) { create(:issue, issue_type: 'Bug', key: 'ISSUE-101') }
  let(:story) { create(:issue, issue_type: 'Story', key: 'ISSUE-102') }

  let(:table) do
    JiraTeamMetrics::Eval::MqlIssuesTable.new([bug, story])
  end

  context "#select_field" do
    it "returns the value of the given field" do
      expect(table.select_field('key', 0)).to eq('ISSUE-101')
      expect(table.select_field('issuetype', 1)).to eq('Story')
    end
  end

  context "#select_rows" do
    it "returns a table with selected rows" do
      results = table.select_rows do |row_index|
        table.select_field('issuetype', row_index) == 'Story'
      end
      expect(results.columns).to eq(['key', 'summary', 'issuetype'])
      expect(results.rows).to eq([story])
    end
  end
end