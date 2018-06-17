require 'rails_helper'

RSpec.describe JiraTeamMetrics::DateRange do
  let(:start_date) { DateTime.new(2001, 1, 1) }

  describe "#to_a" do
    context "if the range is empty" do
      let(:range) { JiraTeamMetrics::DateRange.new(start_date, start_date) }

      it "returns an empty list" do
        expect(range.to_a).to eq([])
      end
    end

    context "if the end date is 1 day ahead of the start" do
      let(:range) { JiraTeamMetrics::DateRange.new(start_date, start_date + 1) }

      it "returns one date (i.e. is end-exclusive)" do
        expect(range.to_a).to eq([start_date])
      end
    end

    context "if the range spans multiple days" do
      let(:range) { JiraTeamMetrics::DateRange.new(start_date, start_date + 3) }

      it "returns all the dates in the range" do
        expect(range.to_a).to eq([
          start_date,
          start_date + 1,
          start_date + 2])
      end
    end
  end

  describe "#overlaps?" do
    let(:range) { JiraTeamMetrics::DateRange.new(start_date, start_date + 2) }

    it "returns true if the ranges are closed and overlap" do
      other = JiraTeamMetrics::DateRange.new(start_date + 1, start_date + 3)
      expect(range.overlaps?(other)).to eq(true)
    end

    it "returns false if the range ends before the other" do
      other = JiraTeamMetrics::DateRange.new(start_date + 3, start_date + 4)
      expect(range.overlaps?(other)).to eq(false)
    end

    it "returns false if the range starts after the other" do
      other = JiraTeamMetrics::DateRange.new(start_date - 2, start_date - 1)
      expect(range.overlaps?(other)).to eq(false)
    end

    it "returns true if the other range overlaps with a nil end date" do
      other = JiraTeamMetrics::DateRange.new(start_date + 1, nil)
      expect(range.overlaps?(other)).to eq(true)
    end

    it "returns false if the other range has a nil end date but doesn't overlap" do
      other = JiraTeamMetrics::DateRange.new(start_date + 3, nil)
      expect(range.overlaps?(other)).to eq(false)
    end

    it "returns true if the range overlaps with a nil end date" do
      range = JiraTeamMetrics::DateRange.new(start_date, nil)
      other = JiraTeamMetrics::DateRange.new(start_date + 1, start_date + 2)
      expect(range.overlaps?(other)).to eq(true)
    end

    it "returns false if the range doesn't overlap with a nil end date" do
      range = JiraTeamMetrics::DateRange.new(start_date, nil)
      other = JiraTeamMetrics::DateRange.new(start_date - 2, start_date - 1)
      expect(range.overlaps?(other)).to eq(false)
    end
  end

  describe "#overlap_with" do
    let(:range) { JiraTeamMetrics::DateRange.new(start_date, start_date + 2) }

    it "returns the overlap range" do
      other = JiraTeamMetrics::DateRange.new(start_date + 1, start_date + 3)
      expect(range.overlap_with(other)).to eq(JiraTeamMetrics::DateRange.new(start_date + 1, start_date + 2))
    end

    it "returns nil when a start time is missing" do
      other = JiraTeamMetrics::DateRange.new(nil, start_date + 3)
      expect(range.overlap_with(other)).to eq(nil)
    end

    it "returns the overlap when the other range has a nil end date" do
      other = JiraTeamMetrics::DateRange.new(start_date + 1, nil)
      expect(range.overlap_with(other)).to eq(JiraTeamMetrics::DateRange.new(start_date + 1, start_date + 2))
    end

    it "returns the overlap with the range has a nil end date" do
      range = JiraTeamMetrics::DateRange.new(start_date, nil)
      other = JiraTeamMetrics::DateRange.new(start_date + 1, start_date + 2)
      expect(range.overlap_with(other)).to eq(JiraTeamMetrics::DateRange.new(start_date + 1, start_date + 2))
    end
  end

  describe "#duration" do
    it "returns the duration in days" do
      range = JiraTeamMetrics::DateRange.new(start_date, start_date + 1.5)
      expect(range.duration).to eq(1.5)
    end
  end

  describe "#to_query" do
    it "returns a string that represents the range as query parameters" do
      range = JiraTeamMetrics::DateRange.new(start_date, start_date + 1)
      expect(range.to_query).to eq("from_date=2001-01-01&to_date=2001-01-02")
    end
  end
end
