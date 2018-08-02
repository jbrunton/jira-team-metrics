require 'rails_helper'

RSpec.describe JiraTeamMetrics::ConfigFileService do
  let(:board) { create(:board) }

  let!(:project) { create(:issue, issue_type: 'Project', board: board) }
  let!(:epic) do
    create(:epic, board: board, links: [{
      'inward_link_type' => 'is included in',
      'issue' => {
        'issue_type' => project.issue_type,
        'key' => project.key
      }
    }])
  end
  let!(:issue1) { create(:issue, board: board, fields: { 'Epic Link' => epic.key }) }
  let!(:issue2) do
    create(:issue, board: board, links: [{
      'inward_link_type' => 'is included in',
      'issue' => {
        'issue_type' => epic.issue_type,
        'key' => epic.key
      }
    }])
  end
  let(:service) { JiraTeamMetrics::IssueLinkerService.new(board) }

  before(:each) do
    service.build_graph
    issue1.reload
    issue2.reload
    epic.reload
  end

  describe "#build_graph" do
    it "links epics" do
      expect(issue1.epic).to eq(epic)
      expect(issue1.epic_key).to eq(epic.key)
      expect(issue2.epic).to eq(nil)
    end

    it "links parents" do
      expect(epic.parent).to eq(project)
      expect(epic.parent_key).to eq(project.key)
      expect(epic.parent_issue_type).to eq(project.issue_type)

      expect(issue1.parent).to eq(nil)
      expect(issue2.parent).to eq(epic)
    end

    it "links projects" do
      expect(epic.project).to eq(project)
      expect(epic.project_key).to eq(project.key)

      expect(issue1.project).to eq(project)
      expect(issue2.project).to eq(project)
    end
  end
end