require 'rails_helper'

RSpec.describe MqlInterpreter do
  describe "#eval" do
    context "when given a field comparison" do
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
  end
end