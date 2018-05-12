require 'rails_helper'

RSpec.describe JiraTeamMetrics::Issue do
  let(:analysis_transition) {
    {
      'date' => '2017-01-01T12:00:00.000-0000',
      'toStatus' => 'Analysis',
      'toStatusCategory' => 'To Do'
    }
  }

  let(:in_progress_transition) {
    {
      'date' => '2017-01-02T12:00:00.000-0000',
      'toStatus' => 'In Progress',
      'toStatusCategory' => 'In Progress'
    }
  }

  let(:in_review_transition) {
    {
      'date' => '2017-01-03T12:00:00.000-0000',
      'toStatus' => 'In Review',
      'toStatusCategory' => 'In Progress'
    }
  }

  let(:in_test_transition) {
    {
      'date' => '2017-01-03T15:00:00.000-0000',
      'toStatus' => 'In Test',
      'toStatusCategory' => 'In Progress'
    }
  }

  let (:done_transition) {
    {
      'date' => '2017-01-03T18:00:00.000-0000',
      'toStatus' => 'Done',
      'toStatusCategory' => 'Done'
    }
  }

  let(:board) { create(:board) }

  let(:issue) {
    create(:issue,
      board: board,
      issue_type: 'Story',
      transitions: [
        analysis_transition,
        in_progress_transition,
        in_review_transition,
        in_test_transition,
        done_transition
      ])
  }

  it "initializes the instance" do
    expect(issue.key).to eq('ISSUE-101')
    expect(issue.summary).to eq('Some Issue')
    expect(issue.issue_type).to eq('Story')
    expect(issue.transitions).to eq([
      analysis_transition,
      in_progress_transition,
      in_review_transition,
      in_test_transition,
      done_transition
    ])
  end

  describe "started_time" do
    context "when passed no parameters" do
      it "returns the time of the first transition to 'In Progress' status category" do
        expect(issue.started_time).to eq(Time.parse('2017-01-02T12:00:00.000-0000'))
      end
    end

    context "when passed a status name" do
      it "returns the time of the first transition to that status" do
        expect(issue.started_time('In Test')).to eq(Time.parse('2017-01-03T15:00:00.000-0000'))
      end
    end

    context "when never started" do
      it "returns nil"
    end
  end

  describe "completed" do
    context "when passed no parameters" do
      it "returns the time of the last transition to 'Done' status category" do
        expect(issue.completed_time).to eq(Time.parse('2017-01-03T18:00:00.000-0000'))
      end
    end

    context "when passed a status name" do
      it "returns the time of the last transition to that status" do
        expect(issue.completed_time('In Test')).to eq(Time.parse('2017-01-03T15:00:00.000-0000'))
      end
    end

    context "when reopened" do
      it "returns nil"
    end
  end

  describe "#cycle_time" do
    it "returns the time in days the issue was in progress" do
      expect(issue.cycle_time).to eq(1.25)
    end
  end

  describe "#churn_metrics" do
    it "returns churn metrics" do
      expect(issue.churn_metrics).to eq({
        review_time: 10.0,
        test_time: 10.0,
        score: 20.0
      })
    end
  end

  describe "#epic" do
    let(:epic) { create(:issue, board: board, issue_type: 'Epic') }

    before(:each) {
      issue.fields = {
        'Epic Link' => epic.key
      }
      issue.save
    }

    it "returns the epic given by the Epic Link field" do
      expect(issue.epic).to eq(epic)
    end

  end
end
