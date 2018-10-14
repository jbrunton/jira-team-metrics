require 'rails_helper'

RSpec.describe JiraTeamMetrics::FormattingHelper do
  describe "#pretty_print_date" do
    let(:date) { DateTime.new(2018, 1, 1).in_time_zone('UTC') }

    it "formats a date" do
      expect(helper.pretty_print_date(date)).to eq('01 Jan 2018 UTC')
    end

    it "can format without a timezone" do
      expect(helper.pretty_print_date(date, show_tz: false)).to eq('01 Jan 2018')
    end

    it "can format without the year" do
      expect(helper.pretty_print_date(date, show_tz: false, hide_year: true)).to eq('01 Jan')
    end

    it "can format without the date" do
      expect(helper.pretty_print_date(date, show_tz: false, month_only: true)).to eq('Jan 2018')
    end
  end

  describe "#pretty_print_time" do
    let(:date) { DateTime.new(2018, 1, 1, 10, 30).in_time_zone('UTC') }

    it "formats a time" do
      expect(helper.pretty_print_time(date)).to eq('01 Jan 2018 10:30 UTC')
    end

    it "returns a dash if passed nil" do
      expect(helper.pretty_print_time(nil)).to eq('-')
    end
  end

  describe "#pretty_print_number" do
    it "formats a number to 2 decimal places" do
      expect(helper.pretty_print_number(2.666)).to eq('2.67')
    end

    it "returns a dash if passed nil" do
      expect(helper.pretty_print_number(nil)).to eq('-')
    end

    it "can round to the nearest integer" do
      expect(helper.pretty_print_number(2.6, round: true)).to eq('3')
    end
  end
end
