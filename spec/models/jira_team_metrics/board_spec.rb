require 'rails_helper'

RSpec.describe JiraTeamMetrics::Board do
  let(:board) { create(:board) }
  
  describe "#sync_from" do
    context "when the rounded date is the same year" do
      it "returns the 1st of the month a given number of months ago" do
        travel_to DateTime.new(2018, 4, 12) do
          expect(board.sync_from(1)).to eq(DateTime.new(2018, 3, 1))
        end
      end
    end

    context "when the rounded date is the previous year" do
      it "returns the 1st of the month a given number of months ago" do
        travel_to DateTime.new(2018, 1, 12) do
          expect(board.sync_from(1)).to eq(DateTime.new(2017, 12, 1))
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
        travel_to DateTime.new(2018, 4, 12) do
          expected_query = "(#{board.query}) AND (statusCategory = \"In Progress\" OR status CHANGED AFTER \"2018-02-01\")"
          expect(board.sync_query(months)).to eq(expected_query)
        end
      end
    end
  end

  describe "#update" do
    context "when READONLY is 1" do
      before(:each) { allow(ENV).to receive(:[]).with('READONLY').and_return(1) }

      it "updates the config" do
        new_attributes = { config_string: "sync:\n  months: 6" }
        board.update(new_attributes)
        expect(board.config.sync_months).to eq(6)
      end
    end
  end
end