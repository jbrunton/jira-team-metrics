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

  describe "#sync_query" do
    context "when no sync options are specified" do
      it "returns the board query" do
        expect(board.sync_query('', '')).to eq(board.query)
      end
    end

    context "when a subquery is given" do
      let(:subquery) { 'issuetype != Bug' }

      it "returns the query with the subquery" do
        expect(board.sync_query(subquery, '')).to eq("(#{board.query}) AND (#{subquery})")
      end
    end

    context "when a since option is given" do
      let(:since) { '-30d' }

      it "returns the query with the since option" do
        expected_query = "(#{board.query}) AND (statusCategory = \"In Progress\" OR status CHANGED AFTER \"#{since}\")"
        expect(board.sync_query('', since)).to eq(expected_query)
      end
    end

    context "when both sync options are given" do
      let(:subquery) { 'issuetype != Bug' }
      let(:since) { '-30d' }

      it "returns the query with both sync options" do
        expected_query = "(#{board.query}) AND ((#{subquery}) AND (statusCategory = \"In Progress\" OR status CHANGED AFTER \"#{since}\"))"
        expect(board.sync_query(subquery, since)).to eq(expected_query)
      end
    end
  end
end