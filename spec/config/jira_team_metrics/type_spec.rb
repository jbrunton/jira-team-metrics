require 'rails_helper'

RSpec.describe JiraTeamMetrics::Config::Types do
  subject { JiraTeamMetrics::Config::Types::String.new }

  describe "#type_check" do
    it "returns true for Strings" do
      expect(subject.type_check("string")).to eq(true)
    end

    it "returns false for other types" do
      expect(subject.type_check(nil)).to eq(false)
      expect(subject.type_check(123)).to eq(false)
    end
  end
  describe "Boolean" do
    subject { JiraTeamMetrics::Config::Types::Boolean.new }

    describe "#type_check" do
      it "returns true for Booleans" do
        expect(subject.type_check(true)).to eq(true)
        expect(subject.type_check(false)).to eq(true)
      end

      it "returns false for other types" do
        expect(subject.type_check(nil)).to eq(false)
        expect(subject.type_check(123)).to eq(false)
      end
    end
  end

  describe "Integer" do
    subject { JiraTeamMetrics::Config::Types::Integer.new }

    describe "#type_check" do
      it "returns true for Integers" do
        expect(subject.type_check(123)).to eq(true)
      end

      it "returns false for other types" do
        expect(subject.type_check(nil)).to eq(false)
        expect(subject.type_check(true)).to eq(false)
      end
    end
  end

  describe "Optional" do
    subject { JiraTeamMetrics::Config::Types::Optional.new() }
  end
end
