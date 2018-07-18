require 'rails_helper'

RSpec.describe JiraTeamMetrics::LinkHelper do
  let(:outward_link) {
    {
      'outward_link_type' => 'blocks',
      'issue' => {
        'key' => 'ISSUE-1',
        'issue_type' => 'Story',
        'summary' => 'Issue 1 summary'
      }
    }
  }

  let(:inward_link) {
    {
      'inward_link_type' => 'is blocked by',
      'issue' => {
        'key' => 'ISSUE-2',
        'issue_type' => 'Story',
        'summary' => 'Issue 2 summary'
      }
    }
  }

  describe "#link_type" do
    it "returns the link type for inward links" do
      expect(helper.link_type(inward_link)).to eq('is blocked by')
    end

    it "returns the link type for outward links" do
      expect(helper.link_type(outward_link)).to eq('blocks')
    end
  end

  describe "#link_summary" do
    let(:board) { create(:board) }

    context "if the linked issue hasn't been synchronized" do
      it "generates a text description of the linked issue" do
        expected_text = "ISSUE-2 – Issue 2 summary".html_safe
        expect(helper.link_summary(inward_link, board)).to eq(expected_text)
      end
    end

    context "if the linked issue was synchronized" do
      let(:issue) { board.issues.create(attributes_for(:issue, key: 'ISSUE-2', summary: 'Issue 2 summary')) }
      let(:issue_url) { '/boards/1/issues/ISSUE-2' }

      before(:each) { allow(helper).to receive(:path_for).with(issue).and_return(issue_url) }

      it "generates a hyperlink to the linked issue" do
        expected_html = "<a href='/boards/1/issues/ISSUE-2'>ISSUE-2</a> – Issue 2 summary".html_safe
        expect(helper.link_summary(inward_link, board)).to eq(expected_html)
      end
    end
  end

  describe "#issue_summary" do
    let(:issue) { create(:issue, key: 'ISSUE-2', summary: 'Issue 2 summary') }
    let(:issue_url) { '/boards/1/issues/ISSUE-2' }

    before(:each) { allow(helper).to receive(:path_for).with(issue).and_return(issue_url) }

    it "returns an html link for the issue" do
      expected_html = "<a href='/boards/1/issues/ISSUE-2'>ISSUE-2</a> – Issue 2 summary".html_safe
      expect(helper.issue_summary(issue)).to eq(expected_html)
    end
  end

  describe "#external_link_url" do
    it "returns an external link for the issue" do
      domain = create(:domain, config_string: 'url: https://jira.example.com')
      expect(helper.external_link_url(inward_link, domain)).to eq('https://jira.example.com/browse/ISSUE-2')
    end
  end
end