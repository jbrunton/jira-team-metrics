require 'rails_helper'

describe JiraTeamMetrics::Epic do
  let(:epic) { create(:epic).as_epic }

  let(:today) { DateTime.new(2016, 6, 1) }

  let!(:issue1) { create(:issue, epic: epic, started_time: today - 10, completed_time: today - 5) }
  let!(:issue2) { create(:issue, epic: epic, started_time: today - 10, completed_time: today - 5) }
  let!(:issue3) { create(:issue, epic: epic, started_time: today - 5) }
  let!(:issue4) { create(:issue, epic: epic) }

  describe "#percent_done" do
    it "returns the percentage of completed issues" do
      expect(epic.percent_done).to eq(50.0)
    end
  end

  describe "#scope" do
    it "returns the scope for the epic" do
      expect(epic.scope).to eq([issue1, issue2, issue3, issue4])
    end
  end

  describe "#completed_scope" do
    it "returns the completed issues for the epic" do
      expect(epic.completed_scope).to eq([issue1, issue2])
    end
  end

  describe "#in_progress_scope" do
    it "returns the in progress issues for the epic" do
      expect(epic.in_progress_scope).to eq([issue3])
    end
  end

  describe "#remaining_scope" do
    it "returns the remaining issues for the epic" do
      expect(epic.remaining_scope).to eq([issue3, issue4])
    end
  end
end