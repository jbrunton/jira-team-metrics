require 'rails_helper'

RSpec.describe JiraTeamMetrics::MqlInterpreter do
  describe "#eval" do
    it "evaluates constants" do
      value = JiraTeamMetrics::MqlInterpreter.new.eval("1")
      expect(value).to eq(1)
    end

    it "performs simple arithmetic" do
      value = JiraTeamMetrics::MqlInterpreter.new.eval("1 + 2")
      expect(value).to eq(3)
    end
  end
end
