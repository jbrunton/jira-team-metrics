require 'rails_helper'

RSpec.describe JiraTeamMetrics::TeamScopeReport do
  let(:board) { create(:board) }

  let(:project) { create(:issue, board: board) }

  let(:scoped_epic) { create(:issue, issue_type: 'Epic', board: board, project: project, fields: { 'Teams' => ['My Team'] }) }
  let(:unscoped_epic) { create(:issue, issue_type: 'Epic', board: board, project: project, fields: { 'Teams' => ['My Team'] }) }

  let(:completed_issues) {
    [
      create(:issue, board: board, fields: { 'Teams' => ['My Team'] }, epic: scoped_epic),
      create(:issue, board: board, fields: { 'Teams' => ['My Team'] }, epic: scoped_epic)
    ]
  }

  let(:incomplete_issues) {
    [
      create(:issue, board: board, status: 'In Progress', fields: { 'Teams' => ['My Team'] }, epic: scoped_epic)
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

  let(:team_report) { JiraTeamMetrics::TeamScopeReport.new('My Team', project, my_team_issues + epics) }

  before(:each) { team_report.build }


  describe "#team" do
    it "returns the team" do
      expect(team_report.team).to eq('My Team')
    end
  end

  describe "#project" do
    it "returns the project" do
      expect(team_report.project).to eq(project)
    end
  end

  describe "#epics" do
    context "when given no training data" do
      it "returns the epics with scope" do
        expect(team_report.epics).to eq([scoped_epic])
      end
    end
  end

  describe "#unscoped_epics" do
    context "when given no training data" do
      it "returns an empty list" do
        expect(team_report.unscoped_epics).to eq([])
      end
    end
  end

  describe "#scope" do
    it "returns the total scope" do
      expect(team_report.scope).to eq(my_team_issues)
    end
  end

  describe "#completed_scope" do
    it "returns the completed scope" do
      expect(team_report.completed_scope).to eq(completed_issues)
    end
  end

  describe "#remaining_scope" do
    it "returns the remaining scope" do
      expect(team_report.remaining_scope).to eq(incomplete_issues)
    end
  end
end
