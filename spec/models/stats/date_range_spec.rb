require 'rails_helper'

RSpec.describe DateRange do
  let(:start_date) { Time.new(2001, 1, 1) }

  describe "#to_a" do
    context "if the range is empty" do
      let(:range) { DateRange.new(start_date, start_date) }

      it "returns an empty list" do
        expect(range.to_a).to eq([])
      end
    end

    context "if the end date is 1 day ahead of the start" do
      let(:range) { DateRange.new(start_date, start_date + 1.day) }

      it "returns one date (i.e. is end-exclusive)" do
        expect(range.to_a).to eq([start_date])
      end
    end

    context "if the range spans multiple days" do
      let(:range) { DateRange.new(start_date, start_date + 3.days) }

      it "returns all the dates in the range" do
        expect(range.to_a).to eq([
          start_date,
          start_date + 1.day,
          start_date + 2.day])
      end
    end
  end

  describe "#overlaps?" do
    let(:range) { DateRange.new(start_date, start_date + 2.days) }

    it "returns true if the ranges are closed and overlap" do
      other = DateRange.new(start_date + 1.day, start_date + 3.days)
      expect(range.overlaps?(other)).to eq(true)
    end

    it "returns false if the range ends before the other" do
      other = DateRange.new(start_date + 3.days, start_date + 4.days)
      expect(range.overlaps?(other)).to eq(false)
    end

    it "returns false if the range starts after the other" do
      other = DateRange.new(start_date - 2.days, start_date - 1.day)
      expect(range.overlaps?(other)).to eq(false)
    end

    it "returns true if the other range overlaps with a nil end date" do
      other = DateRange.new(start_date + 1.day, nil)
      expect(range.overlaps?(other)).to eq(true)
    end

    it "returns false if the other range has a nil end date but doesn't overlap" do
      other = DateRange.new(start_date + 3.day, nil)
      expect(range.overlaps?(other)).to eq(false)
    end

    it "returns true if the range overlaps with a nil end date" do
      range = DateRange.new(start_date, nil)
      other = DateRange.new(start_date + 1.day, start_date + 2.days)
      expect(range.overlaps?(other)).to eq(true)
    end

    it "returns false if the range doesn't overlap with a nil end date" do
      range = DateRange.new(start_date, nil)
      other = DateRange.new(start_date - 2.days, start_date - 1.day)
      expect(range.overlaps?(other)).to eq(false)
    end
  end

  describe "#overlap_with" do
    let(:range) { DateRange.new(start_date, start_date + 2.days) }

    it "returns the overlap range" do
      other = DateRange.new(start_date + 1.day, start_date + 3.days)
      expect(range.overlap_with(other)).to eq(DateRange.new(start_date + 1.day, start_date + 2.days))
    end

    it "returns nil when a start time is missing" do
      other = DateRange.new(nil, start_date + 3.days)
      expect(range.overlap_with(other)).to eq(nil)
    end

    it "returns the overlap when the other range has a nil end date" do
      other = DateRange.new(start_date + 1.day, nil)
      expect(range.overlap_with(other)).to eq(DateRange.new(start_date + 1.day, start_date + 2.days))
    end

    it "returns the overlap with the range has a nil end date" do
      range = DateRange.new(start_date, nil)
      other = DateRange.new(start_date + 1.day, start_date + 2.days)
      expect(range.overlap_with(other)).to eq(DateRange.new(start_date + 1.day, start_date + 2.days))
    end
  end

  describe "#duration" do
    it "returns the duration in days" do
      range = DateRange.new(start_date, start_date + 1.5.days)
      expect(range.duration).to eq(1.5)
    end
  end
end
