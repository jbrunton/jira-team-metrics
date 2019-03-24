require 'rails_helper'

RSpec.describe JiraTeamMetrics::TagsService do
  let(:config_string) do
    <<~CONFIG
    url: https://jira.example.com
    tags:
      - name: Fixed Issues
        path: "$[?(@.fields.resolution.name == 'Fixed')]"
    CONFIG
  end
  let(:domain) { create(:domain, config_string: config_string) }
  let(:board) { create(:board, domain: domain) }

  let!(:issue1) { create(:issue, board: board, json: { 'fields' => { 'resolution' => { 'name' => 'Fixed' } } }) }
  let!(:issue2) { create(:issue, board: board, json: { 'fields' => { 'resolution' => nil } }) }
  let(:notifier) do
    notifier = instance_double('JiraTeamMetrics::StatusNotifier')
    allow(notifier).to receive(:notify_status).with('tagging issues')
    notifier
  end
  let(:service) { JiraTeamMetrics::TagsService.new(board, notifier) }

  before(:each) do
    service.apply_tags
    issue1.reload
    issue2.reload
  end

  describe "#apply_tags" do
    it "applies json tags" do
      expect(issue1.tags).to eq(['Fixed Issues'])
      expect(issue2.tags).to eq([])
    end
  end
end
