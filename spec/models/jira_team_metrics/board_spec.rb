require 'rails_helper'

RSpec.describe JiraTeamMetrics::Board do
  let(:board) { create(:board) }

  describe "::DEFAULT_CONFIG" do
    before(:each) { board.config_string = JiraTeamMetrics::Board::DEFAULT_CONFIG }

    it "specifies cycle_times properties" do
      expect(board.config_property('cycle_times.in_progress')).to eq({
        from: 'In Progress',
        to: 'Done'
      })
      expect(board.config_property('cycle_times.in_review')).to eq({
        from: 'In Review',
        to: 'In Test'
      })
      expect(board.config_property('cycle_times.in_test')).to eq({
        from: 'In Test',
        to: 'Done'
      })
    end

    it "specifies an outliers filter" do
      expect(board.config.filters).to eq([
        JiraTeamMetrics::BoardConfig::ConfigFilter.new(
          'Outliers',
          [{ 'key' => 'ENG-101', 'reason' => 'blocked in test' }])
      ])
    end

    it "specifies an default query" do
      default_query = board.config_property('default_query')
      expect(default_query).to eq("not filter = 'Outliers'")
    end
  end

  describe "#sync_from" do
    context "when the rounded date is the same year" do
      it "returns the 1st of the month a given number of months ago" do
        travel_to Time.new(2018, 4, 12) do
          expect(board.sync_from(1)).to eq(Time.new(2018, 3, 1))
        end
      end
    end

    context "when the rounded date is the previous year" do
      it "returns the 1st of the month a given number of months ago" do
        travel_to Time.new(2018, 1, 12) do
          expect(board.sync_from(1)).to eq(Time.new(2017, 12, 1))
        end
      end
    end
  end

  describe "#sync_query" do
    context "when no sync options are specified" do
      it "returns the board query" do
        expect(board.sync_query(nil)).to eq(board.query)
      end
    end

    context "when a months option is given" do
      let(:months) { 2 }

      it "returns the query with the since option" do
        travel_to Time.new(2018, 4, 12) do
          expected_query = "(#{board.query}) AND (statusCategory = \"In Progress\" OR status CHANGED AFTER \"2018-02-01\")"
          expect(board.sync_query(months)).to eq(expected_query)
        end
      end
    end
  end
end