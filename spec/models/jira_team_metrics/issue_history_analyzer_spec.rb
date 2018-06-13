require 'rails_helper'

RSpec.describe JiraTeamMetrics::Issue do
  let(:analysis_transition) {
    {
        'date' => '2017-01-01T12:00:00.000-0000',
        'toStatus' => 'Analysis',
        'toStatusCategory' => 'To Do'
    }
  }

  let(:in_progress_transition_1) {
    {
        'date' => '2017-01-02T12:00:00.000-0000',
        'toStatus' => 'In Progress',
        'toStatusCategory' => 'In Progress'
    }
  }

  let(:blocked_transition) {
    {
        'date' => '2017-01-03T12:00:00.000-0000',
        'toStatus' => 'Blocked',
        'toStatusCategory' => 'To Do'
    }
  }

  let(:in_progress_transition_2) {
    {
        'date' => '2017-01-04T12:00:00.000-0000',
        'toStatus' => 'In Progress',
        'toStatusCategory' => 'In Progress'
    }
  }

  let (:done_transition) {
    {
        'date' => '2017-01-04T18:00:00.000-0000',
        'toStatus' => 'Done',
        'toStatusCategory' => 'Done'
    }
  }

  let(:issue) {
    create(:issue,
        issue_type: 'Story',
        transitions: [
            analysis_transition,
            in_progress_transition_1,
            blocked_transition,
            in_progress_transition_2,
            done_transition
        ])
  }

  let(:analyzer) { JiraTeamMetrics::IssueHistoryAnalyzer.new(issue) }

  before(:each) { travel_to DateTime.parse('2017-01-05T12:00:00.000-0000') }

  describe "#issue" do
    it "returns the issue" do
      expect(analyzer.issue).to eq(issue)
    end
  end

  describe "#history_as_ranges" do
    it "returns a list of status changes with ranges" do
      expect(analyzer.history_as_ranges).to eq([
          JiraTeamMetrics::IssueHistoryAnalyzer::StatusHistory.new(
              'Analysis',
              'To Do',
              JiraTeamMetrics::DateRange.new(
                  DateTime.parse('2017-01-01T12:00:00.000-0000'),
                  DateTime.parse('2017-01-02T12:00:00.000-0000')
              )
          ),
          JiraTeamMetrics::IssueHistoryAnalyzer::StatusHistory.new(
              'In Progress',
              'In Progress',
              JiraTeamMetrics::DateRange.new(
                  DateTime.parse('2017-01-02T12:00:00.000-0000'),
                  DateTime.parse('2017-01-03T12:00:00.000-0000')
              )
          ),
          JiraTeamMetrics::IssueHistoryAnalyzer::StatusHistory.new(
              'Blocked',
              'To Do',
              JiraTeamMetrics::DateRange.new(
                  DateTime.parse('2017-01-03T12:00:00.000-0000'),
                  DateTime.parse('2017-01-04T12:00:00.000-0000')
              )
          ),
          JiraTeamMetrics::IssueHistoryAnalyzer::StatusHistory.new(
              'In Progress',
              'In Progress',
              JiraTeamMetrics::DateRange.new(
                  DateTime.parse('2017-01-04T12:00:00.000-0000'),
                  DateTime.parse('2017-01-04T18:00:00.000-0000')
              )
          ),
          JiraTeamMetrics::IssueHistoryAnalyzer::StatusHistory.new(
              'Done',
              'Done',
              JiraTeamMetrics::DateRange.new(
                  DateTime.parse('2017-01-04T18:00:00.000-0000'),
                  DateTime.parse('2017-01-05T12:00:00.000-0000')
              )
          )
      ])
    end
  end

  describe "#time_in_category" do
    context "when given no date range" do
      xit "returns the total time in the given category" do
        expect(analyzer.time_in_category('In Progress')).to eq(1.25)
      end
    end

    context "when given a date range" do
      it "returns the total time in the given category in that range" do
        date_range = JiraTeamMetrics::DateRange.new(
            DateTime.parse('2017-01-02T00:00:00.000-0000'),
            DateTime.parse('2017-01-04T00:00:00.000-0000')
        )
        expect(analyzer.time_in_category('In Progress', date_range)).to eq(1.0)
      end
    end
  end
end