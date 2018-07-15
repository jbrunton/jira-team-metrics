require 'rails_helper'

RSpec.describe JiraTeamMetrics::PathHelper do
  before(:each) { create(:domain) }

  describe "#projects_path_singular" do
    it "returns the singular path for the projects issue type" do
      expect(helper.projects_path_singular).to eq('project')
    end
  end

  describe "#projects_path_plural" do
    it "returns the plural path for the projects issue type" do
      expect(helper.projects_path_plural).to eq('projects')
    end
  end

  describe "#projects_name_singular" do
    it "returns the singular name for the projects issue type" do
      expect(helper.projects_name_singular).to eq('Project')
    end
  end

  describe "#projects_name_plural" do
    it "returns the plural name for the projects issue type" do
      expect(helper.projects_name_plural).to eq('Projects')
    end
  end
end
