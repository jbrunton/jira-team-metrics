require 'rails_helper'

RSpec.describe JiraTeamMetrics::SyncBoardJob, type: :job do
  let(:issue_attrs_list) {
    [{
      'key' => 'ISSUE-101',
      'fields' => {},
      'links' => []
    }]
  }

  let!(:domain) { create(:domain) }
  let!(:board) { create(:board, domain: domain, jira_id: 101) }

  describe "#perform" do
    it "syncs issues for the board" do
      expect_any_instance_of(JiraTeamMetrics::JiraClient).to receive(:search_issues).and_return(issue_attrs_list)

      subject.perform(101, domain, {}, nil)

      expect(issue_attrs(domain.boards.find_by(jira_id: 101).issues)).to eq(issue_attrs_list)
    end
  end

  def issue_attrs(issues)
    issues.map do |issue|
      issue.slice('key', 'fields', 'links')
    end
  end
end
