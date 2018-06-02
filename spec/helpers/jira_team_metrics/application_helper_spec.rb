require 'rails_helper'

RSpec.describe JiraTeamMetrics::ApplicationHelper do
  describe "#readonly?" do
    it "returns true if READONLY is set" do
      allow(ENV).to receive(:[]).with('READONLY').and_return(1)
      expect(helper.readonly?).to eq(true)
    end

    it "returns false otherwise" do
      expect(helper.readonly?).to eq(false)
    end
  end

  describe "#syncing?" do
    let(:board) { create(:board) }

    it "returns true if object.syncing is true" do
      board.syncing = true
      expect(helper.syncing?(board)).to eq(true)
    end

    it "returns false if object.syncing is false" do
      board.syncing = false
      expect(helper.syncing?(board)).to eq(false)
    end

    it "returns true if passed nil" do
      expect(helper.syncing?(nil)).to eq(false)
    end
  end
end
