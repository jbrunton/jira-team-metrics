require 'rails_helper'

RSpec.describe JiraTeamMetrics::DescriptiveScopeStatistics do
  let(:now) { DateTime.new(2018, 1, 21, 10, 30) }
  let(:three_weeks_ago) { now - 21 }
  let(:two_weeks_ago) { now - 14 }
  let(:one_week_ago) { now - 7 }

  let(:epics) { [create(:epic), create(:epic)] }
  let(:completed_issues) {
    [
      create(:issue, started_time: three_weeks_ago, completed_time: two_weeks_ago),
      create(:issue, started_time: two_weeks_ago, completed_time: one_week_ago),
      create(:issue, started_time: one_week_ago, completed_time: now)
    ]
  }
  let(:other_issues) { [create(:issue), create(:issue)] }
  let(:issues) { completed_issues + other_issues }

  let(:instance) do
    Class.new do
      include JiraTeamMetrics::DescriptiveScopeStatistics

      def initialize(epics, issues, completed_issues)
        @epics = epics
        @issues = issues
        @completed_issues = completed_issues
      end

      def scope; @issues; end
      def completed_scope; @completed_issues; end
      def epics; @epics; end
    end.new(epics, issues, completed_issues)
  end


  describe "#epic_scope" do
    context "if epics.count > 0" do
      it "returns the average issues per epic" do
        expect(instance.epic_scope).to eq(2.5)
      end
    end

    context "if epics.count = 0" do
      before(:each) { allow(instance).to receive(:epics).and_return([]) }

      it "returns 0" do
        expect(instance.epic_scope).to eq(0)
      end
    end
  end

  describe "#percent_completed" do
    it "returns the percent of completed issues" do
      expect(instance.percent_completed).to eq(60.0)
    end
  end

  describe "#started_date" do
    context "if any issues are completed" do
      it "returns the time the first issue was started" do
        expect(instance.started_date).to eq(three_weeks_ago)
      end
    end

    context "if no issues are started" do
      before(:each) { allow(instance).to receive(:scope).and_return(other_issues) }

      it "returns the current time" do
        travel_to now do
          expect(instance.started_date).to eq(now)
        end
      end
    end
  end

  describe "#second_percentile_started_date"
end