require 'rails_helper'

RSpec.describe JiraTeamMetrics::MqlInterpreter do
  let(:interpreter) { JiraTeamMetrics::MqlInterpreter.new }

  let(:now) { DateTime.new(2018, 1, 1, 10, 30) }
  before(:each) { travel_to now }

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

    it "performs inequality comparisons" do
      expect(eval('1 < 2')).to eq(true)
      expect(eval('2 < 2')).to eq(false)

      expect(eval('2 > 1')).to eq(true)
      expect(eval('2 > 2')).to eq(false)

      expect(eval('1 <= 2')).to eq(true)
      expect(eval('2 <= 2')).to eq(true)
      expect(eval('3 <= 2')).to eq(false)

      expect(eval('2 >= 1')).to eq(true)
      expect(eval('2 >= 2')).to eq(true)
      expect(eval('2 >= 3')).to eq(false)
    end

    it "evaluates fields on LHS of expressions" do
      bug = create(:issue, issue_type: 'Bug')
      story = create(:issue, issue_type: 'Story')

      expect(eval("issuetype = 'Bug'", [bug, story])).to eq([bug])
    end

    it "fails when fields are used on the right hand side" do
      expect{
        eval("'Bug' = issuetype", [])
      }.to raise_error(JiraTeamMetrics::ParserError, JiraTeamMetrics::ParserError::FIELD_RHS_ERROR)
    end

    it "invokes functions" do
      expect(eval('today()')).to eq(now.to_date)
      expect(eval("date('2018-06-01')")).to eq(DateTime.new(2018, 6, 1))
      expect(eval('date(2018, 6, 1)')).to eq(DateTime.new(2018, 6, 1))
    end

    it "evaluates includes expressions" do
      issue1 = create(:issue, fields: { 'teams' => ['Android'] })
      issue2 = create(:issue, fields: { 'teams' => ['iOS'] })
      expect(eval("teams includes 'iOS'", [issue1, issue2])).to eq([issue2])
    end
  end

  def eval(expr, issues = [])
    interpreter.eval(expr, issues)
  end
end
