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
    it "returns the time of the first transition to 'In Progress' status category" do
      expect(issue.started_time).to eq(Time.parse('2017-01-02T12:00:00.000-0000'))
    end

    context "when never started" do
      it "returns nil"
    end
  end

  describe "completed_time" do
    it "returns the time of the last transition to 'Done' status category" do
      expect(issue.completed_time).to eq(Time.parse('2017-01-03T18:00:00.000-0000'))
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

  describe "#started?" do
    it "returns true if the issue is started" do
      issue = create(:issue, transitions: [in_progress_transition])
      expect(issue.started?).to eq(true)
    end

    it "returns false otherwise" do
      issue = create(:issue, transitions: [])
      expect(issue.started?).to eq(false)
    end
  end

  describe "#completed?" do
    it "returns true if the issue is both started and completed" do
      issue = create(:issue, transitions: [in_progress_transition, done_transition])
      expect(issue.completed?).to eq(true)
    end

    it "returns false if the issue is started but not completed" do
      issue = create(:issue, transitions: [in_progress_transition])
      expect(issue.completed?).to eq(false)
    end

    it "returns false if the issue is completed but never started" do
      issue = create(:issue, transitions: [done_transition])
      expect(issue.completed?).to eq(false)
    end
  end

  describe "#in_progress?" do
    it "returns true if the issue is started but not completed" do
      issue = create(:issue, transitions: [in_progress_transition])
      expect(issue.in_progress?).to eq(true)
    end

    it "returns false if the issue is completed" do
      issue = create(:issue, transitions: [in_progress_transition, done_transition])
      expect(issue.in_progress?).to eq(false)
    end

    it "returns false if the issue is not started" do
      issue = create(:issue, transitions: [])
      expect(issue.in_progress?).to eq(false)
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
