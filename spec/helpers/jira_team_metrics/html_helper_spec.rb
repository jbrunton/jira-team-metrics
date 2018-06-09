require 'rails_helper'

RSpec.describe JiraTeamMetrics::HtmlHelper do
  let(:credentials) { JiraTeamMetrics::Credentials.new(username: 'myuser', password: 'password') }

  describe "#form_input" do
    it "returns an html input" do
      expected_html = "<div class=\"field\"><label for=\"credential_username\" class=\"active\">Username</label><input id=\"credential_username\" name=\"credential[username]\" class=\"ui\" value=\"myuser\" type=\"text\" /></div>".html_safe
      expect(helper.form_input(credentials, :username)).to eq(expected_html)
    end
  end
end