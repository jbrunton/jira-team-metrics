require 'rails_helper'

describe JiraTeamMetrics::Epic do
  let(:epic) { create(:epic).as_epic }

  let(:today) { DateTime.new(2016, 6, 1) }

  let!(:issue1) { create(:issue, epic: epic.object, started_time: today - 10, completed_time: today - 5) }
  let!(:issue2) { create(:issue, epic: epic.object, started_time: today - 10, completed_time: today - 5) }
  let!(:issue3) { create(:issue, epic: epic.object, started_time: today - 5) }
  let!(:issue4) { create(:issue, epic: epic.object) }

  before(:each) { travel_to today }

  describe "#scope" do
    it "returns the scope for the epic" do
      expect(epic.scope).to eq([issue1, issue2, issue3, issue4])
    end
  end

  describe "#forecaster" do
    it "returns a forecaster for the epic" do
      expect(epic.forecaster.class).to eq(JiraTeamMetrics::Forecaster)
      expect(epic.forecaster.scope).to eq(epic.scope)
    end
  end
end