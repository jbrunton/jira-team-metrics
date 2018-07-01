require 'rails_helper'

RSpec.describe JiraTeamMetrics::MqlInterpreter do
  let(:board) { create(:board) }

  describe "#eval" do
    context "when given a blank query" do
      let(:issue) { create(:issue, key: 'ISSUE-101', board: board) }

      it "returns all issues" do
        issues = JiraTeamMetrics::MqlInterpreter.new(board, [issue]).eval("")
        expect(issues).to eq([issue])
      end
    end

    context "when given an issue field comparison" do
      let(:issue) { create(:issue, key: 'ISSUE-101', board: board) }

      it "returns issues that match the given value" do
        issues = JiraTeamMetrics::MqlInterpreter.new(board, [issue]).eval("key = 'ISSUE-101'")
        expect(issues).to eq([issue])
      end

      it "filters out issues that do not match the given value" do
        issues = JiraTeamMetrics::MqlInterpreter.new(board, [issue]).eval("key = 'ISSUE-102'")
        expect(issues).to be_empty
      end
    end

    context "when given a jira field comparison" do
      let(:issue) { create(:issue, fields: {'MyField' => 'foo'}, board: board) }

      it "returns issues that match the given value" do
        issues = JiraTeamMetrics::MqlInterpreter.new(board, [issue]).eval("MyField = 'foo'")
        expect(issues).to eq([issue])
      end

      it "filters out issues that do not match the given value" do
        issues = JiraTeamMetrics::MqlInterpreter.new(board, [issue]).eval("MyField = 'bar'")
        expect(issues).to be_empty
      end
    end

    context "when given an object field comparison" do
      let(:issue) { create(:issue, status: 'Some Status', board: board) }

      it "returns issues that match the given value" do
        issues = JiraTeamMetrics::MqlInterpreter.new(board, [issue]).eval("status = 'Some Status'")
        expect(issues).to eq([issue])
      end

      it "filters out issues that do not match the given value" do
        issues = JiraTeamMetrics::MqlInterpreter.new(board, [issue]).eval("status = 'Done'")
        expect(issues).to be_empty
      end
    end

    context "when given an increment comparison" do
      xit "returns issues that match the given value"
      xit "filters out issues that do not match the given value"
    end

    context "when given a disjunction" do
      let(:issue_a) { create(:issue, fields: {'MyField' => 'A'}, board: board) }
      let(:issue_b) { create(:issue, fields: {'MyField' => 'B'}, board: board) }
      let(:issue_c) { create(:issue, fields: {'MyField' => 'C'}, board: board) }

      it "returns issues that match the disjunction" do
        issues = JiraTeamMetrics::MqlInterpreter.new(board, [issue_a, issue_b, issue_c]).eval("MyField = 'A' or MyField = 'B'")
        expect(issues).to eq([issue_a, issue_b])
      end
    end

    context "when given a conjunction" do
      let(:issue_a) { create(:issue, fields: {'FieldA' => 'foo', 'FieldB' => 'baz'}, board: board) }
      let(:issue_b) { create(:issue, fields: {'FieldA' => 'foo', 'FieldB' => 'bar'}, board: board) }
      let(:issue_c) { create(:issue, fields: {'FieldA' => 'bar', 'FieldB' => 'baz'}, board: board) }

      it "returns issues that match the conjunction" do
        issues = JiraTeamMetrics::MqlInterpreter.new(board, [issue_a, issue_b, issue_c]).eval("FieldA = 'foo' and FieldB = 'bar'")
        expect(issues).to eq([issue_b])
      end
    end

    context "when given a nested expression" do
      let(:issue_a) { create(:issue, fields: {'FieldA' => 'foo', 'FieldB' => 'baz'}, board: board) }
      let(:issue_b) { create(:issue, fields: {'FieldA' => 'foo', 'FieldB' => 'bar'}, board: board) }
      let(:issue_c) { create(:issue, fields: {'FieldA' => 'bar', 'FieldB' => 'baz'}, board: board) }

      it "returns the issues that match the expression" do
        issues = JiraTeamMetrics::MqlInterpreter.new(board, [issue_a, issue_b, issue_c]).eval("(FieldA = 'foo' and FieldB = 'bar') or (FieldB = 'baz' and FieldA = 'bar')")
        expect(issues).to eq([issue_b, issue_c])
      end
    end

    context "when given a negated expression" do
      let(:issue_a) { create(:issue, fields: {'MyField' => 'A'}, board: board) }
      let(:issue_b) { create(:issue, fields: {'MyField' => 'B'}, board: board) }
      let(:issue_c) { create(:issue, fields: {'MyField' => 'C'}, board: board) }

      it "negates the expression" do
        issues = JiraTeamMetrics::MqlInterpreter.new(board, [issue_a, issue_b, issue_c]).eval("not MyField = 'A'")
        expect(issues).to eq([issue_b, issue_c])
      end

      it "negates compound expressions" do
        issues = JiraTeamMetrics::MqlInterpreter.new(board, [issue_a, issue_b, issue_c]).eval("not (MyField = 'A' or MyField = 'B')")
        expect(issues).to eq([issue_c])
      end
    end
  end
end