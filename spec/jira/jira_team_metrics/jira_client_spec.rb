require 'rails_helper'

RSpec.describe JiraTeamMetrics::JiraClient do
  let(:credentials) { { username: 'foo', password: 'bar' } }
  let(:domain_url) { 'https://jira.example.com' }
  let(:client) { JiraTeamMetrics::JiraClient.new(domain_url, credentials) }
  let(:domain) { create(:domain, fields: []) }
  let(:issue_json_text) { open(File.join(fixture_path, 'issue.json')).read }
  let(:response_text) {
    <<-END
    {
      "expand": "names,schema",
      "startAt": 0,
      "maxResults": 50,
      "total": 1,
      "issues": [#{issue_json_text}]
    }
    END
  }


  it "makes a request" do
    stub_request(:get, "https://jira.example.com/rest/api/2/search?expand=changelog&maxResults=50").
        to_return(status: 200, body: response_text)
    issues = client.search_issues(domain, {})
    expect(issue_attrs(issues)).to eq([
      { 'key' => 'ISSUE-1', 'summary' => 'Issue Summary' }
    ])
  end

  def issue_attrs(issues)
    issues.map do |attrs|
      attrs.slice('key', 'summary')
    end
  end
end