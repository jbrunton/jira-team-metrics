RSpec.describe Issue do
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

  let(:in_test_transition) {
    {
      'date' => '2017-01-02T18:00:00.000-0000',
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

  let(:issue) {
    Issue.new({
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
        expect(issue.started).to eq(Time.parse('2017-01-02T12:00:00.000-0000'))
      end
    end

    context "when passed a status name" do
      it "returns the time of the first transition to that status" do
        expect(issue.started('In Test')).to eq(Time.parse('2017-01-02T18:00:00.000-0000'))
      end
    end

    context "when never started" do
      it "returns nil"
    end
  end

  describe "completed" do
    context "when passed no parameters" do
      it "returns the time of the last transition to 'Done' status category" do
        expect(issue.completed).to eq(Time.parse('2017-01-03T18:00:00.000-0000'))
      end
    end

    context "when passed a status name" do
      it "returns the time of the last transition to that status" do
        expect(issue.completed('In Test')).to eq(Time.parse('2017-01-02T18:00:00.000-0000'))
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

  describe "#cycle_time_between" do
    it "returns the time in days the issue was between the given states" do
      expect(issue.cycle_time_between('In Progress', 'In Test')).to eq(0.25)
    end
  end
end
