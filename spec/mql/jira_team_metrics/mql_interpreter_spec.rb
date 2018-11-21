require 'rails_helper'

RSpec.describe JiraTeamMetrics::MqlInterpreter do
  let(:interpreter) { JiraTeamMetrics::MqlInterpreter.new }

  describe "#eval" do
    it "evaluates int constants" do
      expect(eval("1")).to eq(1)
      expect(eval("-2")).to eq(-2)
    end

    it "evaluates bool constants" do
      expect(eval('true')).to eq(true)
      expect(eval('false')).to eq(false)
    end

    it "performs arithmetic" do
      expect(eval("1 + 2")).to eq(3)
      expect(eval("(1 + 2) * 3")).to eq(9)
    end

    it "performs boolean operations" do
      expect(eval("true and false")).to eq(false)
      expect(eval("(true or false) and true")).to eq(true)
    end

    it "performs equality comparisons" do
      expect(eval("1 = 1")).to eq(true)
      expect(eval("1 = 2")).to eq(false)

      expect(eval("true = true")).to eq(true)
      expect(eval("true = false")).to eq(false)

      expect(eval("true = 1")).to eq(false)
    end
  end

  def eval(expr)
    interpreter.eval(expr)
  end
end
