require 'rails_helper'

RSpec.describe JiraTeamMetrics::TeamScopeReport do
  let(:now) { DateTime.now }

  let(:board) { create(:board) }
  let(:project) { create(:project, board: board) }

  let(:scoped_epic) { create(:epic, key: 'EPIC-1', board: board, project: project, fields: { 'Teams' => ['My Team'] }) }
  let(:unscoped_epic) { create(:epic, key: 'EPIC-2', board: board, project: project, fields: { 'Teams' => ['My Team'] }) }

  let(:completed_issues) {
    [
      create(:issue, status: 'Done', board: board, fields: { 'Teams' => ['My Team'] }, epic: scoped_epic, started_time: now - 8, completed_time: now - 7),
      create(:issue, status: 'Done', board: board, fields: { 'Teams' => ['My Team'] }, epic: scoped_epic, started_time: now - 7, completed_time: now - 6)
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

  context "when given training data" do
    let(:training_report) { JiraTeamMetrics::TeamScopeReport.new('My Team', project, my_team_issues) }
    let(:trained_report) { JiraTeamMetrics::TeamScopeReport.new('My Team', project, my_team_issues + epics, [training_report]) }

    it "builds predictions" do
      training_report.build
      trained_report.build

      expect(trained_report.trained_throughput).to eq(1.0)
      expect(trained_report.predicted_throughput).to eq(1.0)
    end
  end

  context "when given prediction overrides" do
    let(:config_string) do
      <<~CONFIG
      default_query: filter = 'MyFilter'"
      predictive_scope:
        adjustments_field: Metric Adjustments
      teams:
        - name: My Team
          short_name: myt
      CONFIG
    end

    let(:adjustment_string) do
      <<~END
      myt:
        epic_overrides:
          EPIC-2: 5
      END
    end

    before(:each) do
      project.fields = { 'Metric Adjustments' => adjustment_string }
      board.config_string = config_string
    end

    it "adds predicted scope" do
      training_report = JiraTeamMetrics::TeamScopeReport.new('My Team', project, my_team_issues)
      training_report.build
      team_report = JiraTeamMetrics::TeamScopeReport.new('My Team', project, my_team_issues + epics, [training_report])

      team_report.build

      predicted_issues = team_report.scope.select { |issue| issue.epic == unscoped_epic && issue.status == 'Predicted' }
      expect(predicted_issues.count).to eq(5)
    end
  end
end
