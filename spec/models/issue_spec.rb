require './models/jira/issue'
require 'byebug'

RSpec.describe Jira::Issue do
  let(:analysis_transition) {
    {
      'date' => '2017-01-01T10:00:00.000-0000',
      'status' => 'Analysis',
      'statusCategory' => 'To Do'
    }
  }

  let(:in_progress_transition) {
    {
      'date' => '2017-01-02T10:00:00.000-0000',
      'status' => 'In Progress',
      'statusCategory' => 'In Progress'
    }
  }

  let(:in_test_transition) {
    {
      'date' => '2017-01-02T16:00:00.000-0000',
      'status' => 'In Test',
      'statusCategory' => 'In Progress'
    }
  }

  let (:done_transition) {
    {
      'date' => '2017-02-03T12:00:00.000-0000',
      'status' => 'Done',
      'statusCategory' => 'Done'
    }
  }

  let(:issue) {
    Jira::Issue.new({
      'key' => 'ABC-101',
      'summary' => 'Some Issue',
      'issue_type' => 'Story',
      'transitions' => [
        analysis_transition,
        in_progress_transition,
        in_test_transition,
        done_transition
      ]
    })
  }

  it "initializes the instance" do
    expect(issue.key).to eq('ABC-101')
    expect(issue.summary).to eq('Some Issue')
    expect(issue.issue_type).to eq('Story')
    expect(issue.transitions).to eq([
      analysis_transition,
      in_progress_transition,
      in_test_transition,
      done_transition
    ])
  end

  describe "#to_h" do
    it "returns a hash representation of the instance" do
      expect(issue.to_h).to eq({
        'key' => 'ABC-101',
        'summary' => 'Some Issue',
        'issue_type' => 'Story',
        'transitions' => [
          analysis_transition,
          in_progress_transition,
          in_test_transition,
          done_transition
        ]
      })
    end
  end

  describe "started" do
    context "when passed no parameters" do
      it "returns the time of the first transition to 'In Progress' status category" do
        expect(issue.started).to eq(Time.parse('2017-01-02T10:00:00.000-0000'))
      end
    end

    context "when passed a status name" do
      it "returns the time of the first transition to that status" do
        expect(issue.started('In Test')).to eq(Time.parse('2017-01-02T16:00:00.000-0000'))
      end
    end

    context "when never started" do
      it "returns nil"
    end
  end

  describe "completed" do
    context "when passed no parameters" do
      it "returns the time of the last transition to 'Done' status category" do
        expect(issue.completed).to eq(Time.parse('2017-02-03T12:00:00.000-0000'))
      end
    end

    context "when passed a status name" do
      it "returns the time of the last transition to that status" do
        expect(issue.completed('In Test')).to eq(Time.parse('2017-01-02T16:00:00.000-0000'))
      end
    end

    context "when reopened" do
      it "returns nil"
    end
  end
end
