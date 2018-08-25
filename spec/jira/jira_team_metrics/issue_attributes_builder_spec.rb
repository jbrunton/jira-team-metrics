require 'rails_helper'

RSpec.describe JiraTeamMetrics::IssueAttributesBuilder do
  let(:domain) { create(:domain, fields: [{ 'id' => 'customfield_101', 'name' => 'Global Rank', 'type' => 'any' }]) }
  let(:json_text) { open(File.join(fixture_path, 'issue.json')).read }
  let(:json) { JSON.parse(json_text) }
  let(:builder) { JiraTeamMetrics::IssueAttributesBuilder.new(json, domain) }

  describe "#build" do
    let!(:attrs) { builder.build }

    it "sets the key" do
      expect(attrs['key']).to eq('ISSUE-1')
    end

    it "sets the summary" do
      expect(attrs['summary']).to eq('Issue Summary')
    end

    it "sets the type" do
      expect(attrs['issue_type']).to eq('Issue Type')
    end

    it "sets the type icon" do
      expect(attrs['issue_type_icon']).to eq('http://example.com/icon.png')
    end

    it "sets the issue_created date" do
      expect(attrs['issue_created']).to eq('2018-01-01T10:30:00.000-0000')
    end

    it "sets the status" do
      expect(attrs['status']).to eq('In Progress')
    end

    it "sets any labels" do
      expect(attrs['labels']).to eq(['foo', 'bar'])
    end

    it "sets the global rank" do
      expect(attrs['global_rank']).to eq('2|globalrank:')
    end

    it "sets the resolution" do
      expect(attrs['resolution']).to eq('Resolution')
    end

    it "sets the custom fields" do
      expect(attrs['fields']).to eq({
        'Global Rank' => '2|globalrank:'
      })
    end

    it "sets the transitions" do
      expect(attrs['transitions']).to eq([
        {
          'date' => '2018-01-02T10:30:00.000-0000',
          'fromStatus' => 'Backlog',
          'fromStatusCategory' => 'To Do',
          'toStatus' => 'In Progress',
          'toStatusCategory' => 'In Progress'
        }
      ])
    end

    it "sets the links" do
      expect(attrs['links']).to eq([
        {
          outward_link_type: 'blocks',
          issue: {
            key: 'ISSUE-2',
            issue_type: 'Story',
            summary: 'Blocked Issue'
          }
        },
        {
          inward_link_type: 'is blocked by',
          issue: {
            key: 'ISSUE-3',
            issue_type: 'Story',
            summary: 'Blocking Issue'
          }
        }
      ])
    end
  end
end