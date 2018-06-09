require 'rails_helper'

RSpec.describe JiraTeamMetrics::DescriptiveScopeStatistics do
  let(:epics) { [create(:epic), create(:epic)] }
  let(:completed_issues) { [create(:issue), create(:issue), create(:issue)] }
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


  describe "epic_scope" do
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
end