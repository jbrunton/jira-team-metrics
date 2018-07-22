require 'rails_helper'

describe JiraTeamMetrics::Epic do
  let(:epic) { create(:epic).as_epic }

  let(:today) { DateTime.new(2016, 6, 1) }

  let!(:issue1) { create(:issue, epic: epic, started_time: today - 10, completed_time: today - 5) }
  let!(:issue2) { create(:issue, epic: epic, started_time: today - 10, completed_time: today - 5) }
  let!(:issue3) { create(:issue, epic: epic, started_time: today - 5) }
  let!(:issue4) { create(:issue, epic: epic) }

  before(:each) { travel_to today }

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

  describe "#throughput" do
    context "when passed nil" do
      it "returns the average throughput for the epic so far" do
        expect(epic.throughput(nil)).to eq(0.2) # 2 issues in 10 days = 0.2 / day
      end
    end

    context "when passed an integer" do
      it "returns the throughput for the given rolling window" do
        expect(epic.throughput(5)).to eq(0.4) # 2 issues in 5 days = 0.4 / day
      end
    end
  end

  describe "#forecast" do
    context "when passed nil" do
      it "forecasts the completion date based on the throughput so far" do
        expect(epic.forecast(nil)).to eq(today + 10) # 2 remaining issues at 0.2 / day
      end
    end

    context "when passed an integer" do
      it "forecasts the completion date based on the throughput for the given window" do
        expect(epic.forecast(5)).to eq(today + 5) # 2 remaining issues at 0.4 / day
      end
    end
  end
end