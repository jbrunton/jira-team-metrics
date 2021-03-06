require 'rails_helper'

RSpec.describe JiraTeamMetrics::Board do
  let(:board) { create(:board) }
  let!(:project) { create(:project, board: board) }
  let!(:epic) { create(:epic, project: project) }
  let!(:story) { create(:issue, epic: epic) }

  describe "#projects" do
    it "returns a list of issues that are projects" do
      expect(board.projects).to eq([project])
    end
  end

  describe "#epics" do
    it "returns a list of epics" do
      expect(board.epics).to eq([epic])
    end

    it "decorates the list" do
      expect(board.epics.first.class).to eq(JiraTeamMetrics::Epic)
    end
  end

  describe "#issues_in_epic" do
    it "returns the issues in an epic" do
      expect(board.issues_in_epic(epic)).to eq([story])
    end
  end

  describe "#issues_in_project" do
    context "when recursive = false" do
      let(:opts) { { recursive: false} }

      it "returns the issues directly linked to the project" do
        expect(board.issues_in_project(project, opts)).to eq([epic])
      end
    end

    context "when recursive = true" do
      let(:opts) { { recursive: true} }

      it "returns the issues in a project recursively" do
        expect(board.issues_in_project(project, opts)).to eq([epic, story])
      end
    end
  end
  
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
        expect(board.config.sync.months).to eq(6)
      end
    end
  end
end