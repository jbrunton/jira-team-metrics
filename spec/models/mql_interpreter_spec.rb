require 'rails_helper'

RSpec.describe MqlInterpreter do
  describe "#eval" do
    context "when given an issue field comparison" do
      let(:issue) { create(:issue, key: 'ISSUE-101') }

      it "returns issues that match the given value" do
        issues = MqlInterpreter.new([issue]).eval("key = 'ISSUE-101'")
        expect(issues).to eq([issue])
      end

      it "filters out issues that do not match the given value" do
        issues = MqlInterpreter.new([issue]).eval("key = 'ISSUE-102'")
        expect(issues).to be_empty
      end
    end

    context "when given a custom field comparison" do
      let(:issue) { create(:issue, fields: {'MyField' => 'foo'}) }

      it "returns issues that match the given value" do
        issues = MqlInterpreter.new([issue]).eval("MyField = 'foo'")
        expect(issues).to eq([issue])
      end

      it "filters out issues that do not match the given value" do
        issues = MqlInterpreter.new([issue]).eval("MyField = 'bar'")
        expect(issues).to be_empty
      end
    end

    context "when given a disjunction" do
      let(:issue_a) { create(:issue, fields: {'MyField' => 'A'}) }
      let(:issue_b) { create(:issue, fields: {'MyField' => 'B'}) }
      let(:issue_c) { create(:issue, fields: {'MyField' => 'C'}) }

      it "returns issues that match the disjunction" do
        issues = MqlInterpreter.new([issue_a, issue_b, issue_c]).eval("MyField = 'A' or MyField = 'B'")
        expect(issues).to eq([issue_a, issue_b])
      end
    end

    context "when given a conjunction" do
      let(:issue_a) { create(:issue, fields: {'FieldA' => 'foo', 'FieldB' => 'baz'}) }
      let(:issue_b) { create(:issue, fields: {'FieldA' => 'foo', 'FieldB' => 'bar'}) }
      let(:issue_c) { create(:issue, fields: {'FieldA' => 'bar', 'FieldB' => 'baz'}) }

      it "returns issues that match the conjunction" do
        issues = MqlInterpreter.new([issue_a, issue_b, issue_c]).eval("FieldA = 'foo' and FieldB = 'bar'")
        expect(issues).to eq([issue_b])
      end
    end

    context "when given a nested expression" do
      let(:issue_a) { create(:issue, fields: {'FieldA' => 'foo', 'FieldB' => 'baz'}) }
      let(:issue_b) { create(:issue, fields: {'FieldA' => 'foo', 'FieldB' => 'bar'}) }
      let(:issue_c) { create(:issue, fields: {'FieldA' => 'bar', 'FieldB' => 'baz'}) }

      it "returns the issues that match the expression" do
        issues = MqlInterpreter.new([issue_a, issue_b, issue_c]).eval("(FieldA = 'foo' and FieldB = 'bar') or (FieldB = 'baz' and FieldA = 'bar')")
        expect(issues).to eq([issue_b, issue_c])
      end
    end

    context "when given a negated expression" do
      let(:issue_a) { create(:issue, fields: {'MyField' => 'A'}) }
      let(:issue_b) { create(:issue, fields: {'MyField' => 'B'}) }
      let(:issue_c) { create(:issue, fields: {'MyField' => 'C'}) }

      it "negates the expression" do
        issues = MqlInterpreter.new([issue_a, issue_b, issue_c]).eval("not MyField = 'A'")
        expect(issues).to eq([issue_b, issue_c])
      end

      it "negates compound expressions" do
        issues = MqlInterpreter.new([issue_a, issue_b, issue_c]).eval("not (MyField = 'A' or MyField = 'B')")
        expect(issues).to eq([issue_c])
      end
    end
  end
end