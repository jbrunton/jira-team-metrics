require 'rails_helper'

RSpec.describe JiraTeamMetrics::IssueFieldResolver do
  let(:project) { create(:project) }
  let(:epic) { create(:epic, project: project) }
  let(:started_time) { DateTime.new(2017, 1, 1) }
  let(:completed_time) { DateTime.new(2017, 2, 1) }
  let(:issue) do
    create(:issue,
      key: 'ISSUE-101',
      summary: 'Some Issue',
      epic: epic,
      project: project,
      status: 'In Progress',
      fields: {'MyField' => 'foo'},
      labels: ['foo'],
      started_time: started_time,
      completed_time: completed_time)
  end

  let(:resolver) { JiraTeamMetrics::IssueFieldResolver.new(issue) }

  describe "#resolve" do
    it "resolves object fields" do
      expect(resolver.resolve('key')).to eq('ISSUE-101')
      expect(resolver.resolve('issuetype')).to eq('Story')
      expect(resolver.resolve('summary')).to eq('Some Issue')
      expect(resolver.resolve('status')).to eq('In Progress')
      expect(resolver.resolve('statusCategory')).to eq('In Progress')
      expect(resolver.resolve('hierarchyLevel')).to eq('Scope')
      expect(resolver.resolve('labels')).to eq(['foo'])
    end

    it "resolves Jira fields" do
      expect(resolver.resolve('MyField')).to eq('foo')
    end

    it "resolves the project key" do
      expect(resolver.resolve('project')).to eq(project.key)
    end

    it "resolves the epic key" do
      expect(resolver.resolve('epic')).to eq(epic.key)
    end

    it "resolves started and completed times" do
      expect(resolver.resolve('startedTime')).to eq(started_time)
      expect(resolver.resolve('completedTime')).to eq(completed_time)
    end

    it "resolves cycle time" do
      expect(resolver.resolve('cycleTime')).to eq(31)
    end
  end
end