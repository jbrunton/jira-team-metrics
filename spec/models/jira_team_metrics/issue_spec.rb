require 'rails_helper'

RSpec.describe JiraTeamMetrics::Issue do
  before(:each) { create(:domain) }

  let(:project) { create(:project) }
  let(:epic) { create(:epic) }
  let(:story) { create(:issue, epic: epic) }

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

  let (:released_transition) {
    {
        'date' => '2017-01-04T18:00:00.000-0000',
        'toStatus' => 'Done',
        'toStatusCategory' => 'Done'
    }
  }

  let (:reopened_transition) {
    {
      'date' => '2017-01-04T18:00:00.000-0000',
      'toStatus' => 'In Progress',
      'toStatusCategory' => 'In Progress'
    }
  }

  let(:board) { create(:board) }

  let(:issue) {
    create(:issue,
      key: 'ISSUE-101',
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
    expect(issue.key).to match(/ISSUE-\d+/)
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

  describe "#hierarchy_level" do
    it "returns the hierarchy level for the issue" do
      {
        issue => 'Scope',
        epic => 'Epic',
        project => 'Project'
      }.each do |issue, expected_hierarchy_level|
        expect(issue.hierarchy_level).to eq(expected_hierarchy_level)
      end
    end
  end

  describe "#teams" do
    context "for epics" do
      let(:epic) { create(:issue, board: board, issue_type: 'Epic', fields: { 'Teams' => ['Android', 'iOS']}) }

      it "returns the teams assigned to the epic" do
        expect(epic.teams).to eq(['Android', 'iOS'])
      end
    end

    context "for issues" do
      let(:epic) { create(:issue, board: board, issue_type: 'Epic', fields: { 'Teams' => ['Android', 'iOS']}) }

      it "inherits teams from the parent epic if none are assigned" do
        issue = create(:issue, board: board, issue_type: 'Epic', fields: {
          'Teams' => ['Android', 'iOS'],
          'Epic Link' => epic.key
        })
        expect(issue.teams).to eq(['Android', 'iOS'])
      end

      it "returns the teams from the issue if assigned" do
        issue = create(:issue, board: board, issue_type: 'Epic', fields: {
          'Teams' => ['Android'],
          'Epic Link' => epic.key
        })
        expect(issue.teams).to eq(['Android'])
      end
    end
  end

  describe "#is_epic?" do
    it "returns true iff issue_type == 'Epic'" do
      expect(create(:epic).is_epic?).to eq(true)
      expect(create(:issue).is_epic?).to eq(false)
    end
  end

  describe "#is_project?" do
    it "returns true iff the issue_type matches the project type" do
      expect(create(:project).is_project?).to eq(true)
      expect(create(:issue).is_project?).to eq(false)
    end
  end

  describe "#is_scope?" do
    it "returns true iff the issue_type is scope" do
      expect(create(:issue).is_scope?).to eq(true)
      expect(create(:epic).is_scope?).to eq(false)
      expect(create(:project).is_scope?).to eq(false)
    end
  end

  describe "started_time" do
    context "if is_scope? is true" do
      it "returns the time of the first transition to 'In Progress' status category" do
        expect(issue.started_time).to eq(DateTime.parse(in_progress_transition['date']))
      end

      it "returns nil if not started" do
        issue.transitions = []
        expect(issue.started_time).to eq(nil)
      end
    end

    context "if is_epic? is true" do
      let(:epic) { create(:epic) }
      let(:started_time) { DateTime.new(2018, 6, 1) }

      it "returns the time of the first started issue in the epic" do
        create(:issue, epic: epic, started_time: started_time + 1)
        create(:issue, epic: epic, started_time: started_time)
        expect(epic.started_time).to eq(started_time)
      end

      it "returns nil if no issues have been started" do
        expect(epic.started_time).to eq(nil)
      end
    end
  end

  describe "completed_time" do
    context "if is_scope? is true" do
      it "returns the time of the last transition to 'Done' status category" do
        expect(issue.completed_time).to eq(DateTime.parse(done_transition['date']))
      end

      it "returns nil if there are no transitions" do
        issue.transitions = []
        expect(issue.completed_time).to eq(nil)
      end

      it "returns nil if the issue was reopened" do
        issue.transitions << reopened_transition
        expect(issue.completed_time).to eq(nil)
      end

      it "returns the time of the first completed transition if the issue moves through several done transitions" do
        issue.transitions << released_transition
        expect(issue.completed_time).to eq(DateTime.parse(done_transition['date']))
      end
    end

    context "if is_epic? is true" do
      let(:epic) { create(:epic) }
      let(:started_time) { DateTime.new(2018, 6, 1) }
      let(:completed_time) { DateTime.new(2018, 7, 1) }

      it "returns the time of the first started issue in the epic" do
        create(:issue, epic: epic, started_time: started_time, completed_time: started_time + 1)
        create(:issue, epic: epic, started_time: completed_time - 1, completed_time: completed_time)
        expect(epic.completed_time).to eq(completed_time)
      end

      it "returns nil if no issues have been completed" do
        expect(epic.started_time).to eq(nil)
      end
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

    it "returns true if the issue is completed but never started" do
      issue = create(:issue, transitions: [done_transition])
      expect(issue.completed?).to eq(true)
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

  describe "completed_during?" do
    it "returns true if the issue was completed during the given range" do
      date_range = JiraTeamMetrics::DateRange.new(DateTime.new(2017,1,3), DateTime.new(2017,1,4))
      expect(issue.completed_during?(date_range)).to eq(true)
    end

    it "returns false if the issue was completed outside the given range" do
      date_range = JiraTeamMetrics::DateRange.new(DateTime.new(2017,1,1), DateTime.new(2017,1,2))
      expect(issue.completed_during?(date_range)).to eq(false)
    end

    it "returns false if the issue is not completed" do
      date_range = JiraTeamMetrics::DateRange.new(DateTime.new(2017,1,3), DateTime.new(2017,1,4))
      issue = create(:issue, transitions: [in_progress_transition])
      expect(issue.completed_during?(date_range)).to eq(false)
    end
  end

  describe "#in_progress_during?" do
    context "when the issue is completed" do
      it "returns true if the issue was completed during the given range" do
        date_range = JiraTeamMetrics::DateRange.new(DateTime.new(2017,1,3), DateTime.new(2017,1,4))
        expect(issue.in_progress_during?(date_range)).to eq(true)
      end

      it "returns true if the issue was completed after the given range but overlaps" do
        date_range = JiraTeamMetrics::DateRange.new(DateTime.new(2017,1,2), DateTime.new(2017,1,3))
        expect(issue.in_progress_during?(date_range)).to eq(true)
      end

      it "returns false if the issue was started after the given range" do
        date_range = JiraTeamMetrics::DateRange.new(DateTime.new(2017,1,1), DateTime.new(2017,1,2))
        expect(issue.in_progress_during?(date_range)).to eq(false)
      end

      it "returns false if the issue was completed before the given range" do
        date_range = JiraTeamMetrics::DateRange.new(DateTime.new(2017,4,1), DateTime.new(2017,5,2))
        expect(issue.in_progress_during?(date_range)).to eq(false)
      end
    end

    context "when the issue is started but not completed" do
      let(:issue) { create(:issue, transitions: [in_progress_transition]) }

      it "returns true if the issue was started before the range start date" do
        date_range = JiraTeamMetrics::DateRange.new(DateTime.new(2017,1,3), DateTime.new(2017,1,4))
        expect(issue.in_progress_during?(date_range)).to eq(true)
      end

      it "returns true if the issue was started before the range end date" do
        date_range = JiraTeamMetrics::DateRange.new(DateTime.new(2017,1,2), DateTime.new(2017,1,3))
        expect(issue.in_progress_during?(date_range)).to eq(true)
      end

      it "returns false if the issue was started after the given range" do
        date_range = JiraTeamMetrics::DateRange.new(DateTime.new(2017,1,1), DateTime.new(2017,1,2))
        expect(issue.in_progress_during?(date_range)).to eq(false)
      end
    end
  end

  describe "#domain_url" do
    it "returns the url for the issue on the Jira domain" do
      expect(issue.domain_url).to eq('https://jira.example.com/browse/ISSUE-101')
    end
  end
end
