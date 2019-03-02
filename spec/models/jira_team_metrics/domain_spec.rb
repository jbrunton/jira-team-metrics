require 'rails_helper'

RSpec.describe JiraTeamMetrics::Domain do
  let!(:domain) { create(:domain, active: true) }

  describe "#get_instance" do
    it "returns the active domain instance" do
      expect(JiraTeamMetrics::Domain.get_active_instance).to eq(domain)
    end
  end

  describe "#short_team_name" do
    it "returns a shortened version of the team name" do
      expect(domain.short_team_name('Android')).to eq('and')
    end

    it "strips whitespace" do
      expect(domain.short_team_name('My Team')).to eq('myt')
    end

    it "looks up the short team name if given in the config" do
      domain.config_string = "teams:\n- name: Mobile\n  short_name: mobi"
      expect(domain.short_team_name('Mobile')).to eq('mobi')
    end
  end

  describe "#status_color_for" do
    it "returns the color for the given status category" do
      [
        { 'To Do'       => 'red' },
        { 'Predicted'   => 'orange' },
        { 'In Progress' => 'green' },
        { 'Done'        => 'blue' }
      ].each do |category, expected_color|
        expect(domain.status_color_for(category)).to eq(expected_color)
      end
    end
  end
end