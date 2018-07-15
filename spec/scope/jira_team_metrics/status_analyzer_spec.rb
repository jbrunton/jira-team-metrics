require 'rails_helper'

RSpec.describe JiraTeamMetrics::StatusAnalyzer do
  let(:today) { DateTime.new(2018, 6, 1) }
  let(:target_date) { '2018-07-01' }

  let(:project) { create(:project, fields: {'Target Date' => target_date}) }
  let(:team_report) { instance_double("JiraTeamMetrics::TeamScopeReport") }
  let(:status_analyzer) { JiraTeamMetrics::StatusAnalyzer.new(team_report) }

  before(:each) do
    travel_to today
    allow(status_analyzer).to receive(:project).and_return(project)
  end

  describe "#analyzer" do
    context "when done" do
      before(:each) do
        allow(status_analyzer).to receive(:remaining_scope).and_return([])
      end

      it "returns a green status" do
        status_analyzer.analyze
        expect(status_analyzer.status_color).to eq('blue')
        expect(status_analyzer.status_reason).to eq('Done.')
      end
    end

    context "when target date is in the past" do
      before(:each) do
        project.fields['Target Date'] = '2018-05-01'
        allow(status_analyzer).to receive(:remaining_scope).and_return([create(:issue)])
      end

      it "returns a red status" do
        status_analyzer.analyze
        expect(status_analyzer.status_color).to eq('red')
        expect(status_analyzer.status_reason).to eq('Target date is in the past.')
      end
    end

    context "when using rolling forecasts" do
      before(:each) do
        expect(team_report).to receive(:use_rolling_forecast?).and_return(true)
      end

      context "when on target" do
        before(:each) do
          allow(team_report).to receive(:remaining_scope).and_return([create(:issue)])
          allow(team_report).to receive(:forecast_completion_date).and_return(today + 15)
        end

        it "returns an on target status" do
          status_analyzer.analyze
          expect(status_analyzer.status_color).to eq('green')
          expect(status_analyzer.status_reason).to eq('Using rolling forecast. Forecast is on target.')
        end
      end

      context "when over target by < 20%" do
        before(:each) do
          allow(team_report).to receive(:remaining_scope).and_return([create(:issue)])
          allow(team_report).to receive(:forecast_completion_date).and_return(today + 35.8)
        end

        it "returns a yellow status" do
          status_analyzer.analyze
          expect(status_analyzer.status_color).to eq('yellow')
          expect(status_analyzer.status_reason).to eq('Using rolling forecast. Forecast is at risk, over target by 19% of time remaining.')
        end
      end

      context "when over target by > 20%" do
        before(:each) do
          allow(team_report).to receive(:remaining_scope).and_return([create(:issue)])
          allow(team_report).to receive(:forecast_completion_date).and_return(today + 36)
        end

        it "returns an on target status" do
          status_analyzer.analyze
          expect(status_analyzer.status_color).to eq('red')
          expect(status_analyzer.status_reason).to eq('Using rolling forecast. Forecast is at risk, over target by 20% of time remaining.')
        end
      end
    end

    context "when using trained forecasts" do
      before(:each) do
        expect(team_report).to receive(:use_rolling_forecast?).and_return(false)
        allow(team_report).to receive(:remaining_scope).and_return([create(:issue)])
        allow(team_report).to receive(:forecast_completion_date).and_return(today + 15)
      end

      it "changes the status reason accordingly" do
        status_analyzer.analyze
        expect(status_analyzer.status_color).to eq('green')
        expect(status_analyzer.status_reason).to eq('< 5 issues completed, using predicted forecast. Forecast is on target.')
      end
    end
  end
end