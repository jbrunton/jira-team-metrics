require 'rails_helper'

RSpec.describe JiraTeamMetrics::TeamAdjustment do
  let(:adjustments) { {} }

  describe "#adjusted_epic_scope" do
    context "when no adjustments are given" do
      it "returns nil" do
        team_adjustment = JiraTeamMetrics::TeamAdjustment.new(adjustments)
        expect(team_adjustment.adjusted_epic_scope(2.0)).to eq(nil)
      end
    end

    context "when an epic scope value is given" do
      before(:each) { adjustments[:epic_scope] = 3.0 }

      it "returns the given epic scope" do
        team_adjustment = JiraTeamMetrics::TeamAdjustment.new(adjustments)
        expect(team_adjustment.adjusted_epic_scope(2.0)).to eq(3.0)
      end
    end

    context "when an epic scope factor is given" do
      before(:each) { adjustments[:epic_scope_factor] = 2.0 }

      it "returns the adjusted epic scope" do
        team_adjustment = JiraTeamMetrics::TeamAdjustment.new(adjustments)
        expect(team_adjustment.adjusted_epic_scope(2.0)).to eq(4.0)
      end
    end
  end

  describe "#adjusted_throughput" do
    context "when no adjustments are given" do
      it "returns nil" do
        team_adjustment = JiraTeamMetrics::TeamAdjustment.new(adjustments)
        expect(team_adjustment.adjusted_throughput(2.0)).to eq(nil)
      end
    end

    context "when an throughput value is given" do
      before(:each) { adjustments[:throughput] = 14.0 }

      it "returns the given throughput (per day)" do
        team_adjustment = JiraTeamMetrics::TeamAdjustment.new(adjustments)
        expect(team_adjustment.adjusted_throughput(2.0)).to eq(2.0)
      end
    end

    context "when an throughput factor is given" do
      before(:each) { adjustments[:throughput_factor] = 2.0 }

      it "returns the adjusted throughput" do
        team_adjustment = JiraTeamMetrics::TeamAdjustment.new(adjustments)
        expect(team_adjustment.adjusted_throughput(2.0)).to eq(4.0)
      end
    end
  end
end
