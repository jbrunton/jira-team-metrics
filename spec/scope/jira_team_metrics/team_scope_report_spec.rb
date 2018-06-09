require 'rails_helper'

RSpec.describe JiraTeamMetrics::TeamScopeReport do
  let(:board) { create(:board) }

  let(:delivery) { create(:issue, board: board) }

  let(:scoped_epic) { create(:issue, issue_type: 'Epic', board: board, fields: { 'Teams' => ['My Team'] }) }
  let(:unscoped_epic) { create(:issue, issue_type: 'Epic', board: board, fields: { 'Teams' => ['My Team'] }) }

  let(:completed_issues) {
    [
      create(:issue, board: board, fields: { 'Teams' => ['My Team'], 'Epic Link' => scoped_epic.key }),
      create(:issue, board: board, fields: { 'Teams' => ['My Team'], 'Epic Link' => scoped_epic.key })
    ]
  }

  let(:incomplete_issues) {
    [
      create(:issue, board: board, status: 'In Progress', fields: { 'Teams' => ['My Team'], 'Epic Link' => scoped_epic.key })
    ]
  }

  let(:my_team_issues) {
    completed_issues + incomplete_issues
  }

  let(:other_issues) {
    [
      create(:issue, board: board),
      create(:issue, board: board)
    ]
  }

  let(:issues) {
    my_team_issues + other_issues
  }

  let(:epics) {
    [scoped_epic, unscoped_epic]
  }

  describe ".issues_for_team" do
    it "filters the given issues by team" do
      filtered_issues = JiraTeamMetrics::TeamScopeReport.issues_for_team(issues, 'My Team')
      expect(filtered_issues).to eq(my_team_issues)
    end

    it "filters for issues with no team" do
      filtered_issues = JiraTeamMetrics::TeamScopeReport.issues_for_team(issues, 'None')
      expect(filtered_issues).to eq(other_issues)
    end
  end

  describe "#build" do
    context "when given no training data" do
      let(:team_report) { JiraTeamMetrics::TeamScopeReport.new('My Team', delivery, my_team_issues + epics) }

      before(:each) { team_report.build }

      it "describes some basic attributes of the scope" do
        expect(team_report.team).to eq('My Team')
        expect(team_report.increment).to eq(delivery)
      end

      it "describes the epic scope, ignoring epics with no scope" do
        expect(team_report.epics).to eq([scoped_epic])
        expect(team_report.unscoped_epics).to eq([])
      end

      it "describes the total scope" do
        expect(team_report.scope).to eq(my_team_issues)
      end

      it "describes the completed scope" do
        expect(team_report.completed_scope).to eq(completed_issues)
      end

      it "describes the remaining scope" do
        expect(team_report.remaining_scope).to eq(incomplete_issues)
      end
    end
  end
end
