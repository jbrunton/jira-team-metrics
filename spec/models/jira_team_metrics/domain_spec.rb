require 'rails_helper'

RSpec.describe JiraTeamMetrics::Domain do
  let!(:domain) { create(:domain) }

  describe "#get_instance" do
    it "returns the domain instance" do
      expect(JiraTeamMetrics::Domain.get_instance).to eq(domain)
    end
  end

  describe "#short_team_name" do
    it "returns a shortened version of the team name" do
      expect(domain.short_team_name("Android")).to eq("and")
    end

    it "looks up the short team name if given in the config" do
      domain.config_string = "teams:\n- name: Mobile\n  short_name: mobi"
      expect(domain.short_team_name("Mobile")).to eq("mobi")
    end
  end
end