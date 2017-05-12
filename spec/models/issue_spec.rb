require './models/jira/issue'
require 'byebug'

RSpec.describe Jira::Issue do
  let(:in_progress_transition) {
    {
      'date' => '2017-01-01T10:00:00.000-0000',
      'status' => 'In Progress',
      'statusCategory' => 'In Progress'
    }
  }

  let (:done_transition) {
    {
      'date' => '2017-02-01T16:00:00.000-0000',
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
        in_progress_transition,
        done_transition
      ]
    })
  }

  it "initializes the instance" do
    expect(issue.key).to eq('ABC-101')
    expect(issue.summary).to eq('Some Issue')
    expect(issue.issue_type).to eq('Story')
    expect(issue.transitions).to eq([
      in_progress_transition,
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
          in_progress_transition,
          done_transition
        ]
      })
    end
  end
end
