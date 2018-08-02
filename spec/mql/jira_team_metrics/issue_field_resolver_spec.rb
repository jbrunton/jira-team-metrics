require 'rails_helper'

RSpec.describe JiraTeamMetrics::IssueFieldResolver do
  let(:project) { create(:project) }
  let(:epic) { create(:epic, project: project) }
  let(:issue) do
    create(:issue,
      key: 'ISSUE-101',
      summary: 'Some Issue',
      epic: epic,
      project: project,
      status: 'In Progress',
      fields: {'MyField' => 'foo'})
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
  end
end