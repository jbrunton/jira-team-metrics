require 'rails_helper'

RSpec.describe JiraTeamMetrics::JiraClient do
  let(:credentials) { { username: 'foo', password: 'bar' } }
  let(:domain_url) { 'https://jira.example.com' }
  let(:client) { JiraTeamMetrics::JiraClient.new(domain_url, credentials) }
  let(:domain) { create(:domain, fields: []) }
  let(:issue_json_text) { open(File.join(fixture_path, 'issue.json')).read }
  let(:issues_response_text) {
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

  let(:fields_response) do
    <<-END
    [
      {
        "id": "customfield_12345",
        "name": "My Field",
        "schema": {
          "type": "string",
          "custom": "com.atlassian.jira.plugin.system.customfieldtypes:textarea",
          "customId": 12345
        }
      }
    ]
    END
  end

  describe "#search_issues" do
    it "makes a request" do
      stub_request(:get, "https://jira.example.com/rest/api/2/search?expand=changelog&maxResults=50").
          to_return(status: 200, body: issues_response_text)
      issues = client.search_issues(domain, {})
      expect(issue_attrs(issues)).to eq([
        { 'key' => 'ISSUE-1', 'summary' => 'Issue Summary' }
      ])
    end
  end

  describe "get_fields" do
    it "fetches fields from the Jira instance" do
      stub_request(:get, "https://jira.example.com/rest/api/2/field").
        to_return(status: 200, body: fields_response)
      fields = client.get_fields
      expect(fields).to eq([
        {'id'=>'customfield_12345', 'name'=>'My Field', :type=>'string'}
      ])
    end
  end

  def issue_attrs(issues)
    issues.map do |attrs|
      attrs.slice('key', 'summary')
    end
  end
end