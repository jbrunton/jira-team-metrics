require 'rails_helper'

RSpec.describe JiraTeamMetrics::Domain do
  describe "#get_instance" do
    it "returns the domain instance" do
      domain = create(:domain)
      expect(JiraTeamMetrics::Domain.get_instance).to eq(domain)
    end
  end

  describe "#short_team_name" do
    it "returns a shortened version of the team name" do
      expect(JiraTeamMetrics::Domain.get_instance.short_team_name("Android")).to eq("and")
    end
  end
end