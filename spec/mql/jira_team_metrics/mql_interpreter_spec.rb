require 'rails_helper'

RSpec.describe JiraTeamMetrics::MqlInterpreter do
  let(:interpreter) { JiraTeamMetrics::MqlInterpreter.new }

  let(:board) { create(:board) }

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

    it "evaluates fields" do
      bug = create(:issue, issue_type: 'Bug')
      story = create(:issue, issue_type: 'Story')

      expect(eval("issuetype = 'Bug'", [bug, story])).to eq([bug])
    end

    it "invokes functions" do
      expect(eval('today()')).to eq(now.to_date)
      expect(eval("date('2018-06-01')")).to eq(DateTime.new(2018, 6, 1))
      expect(eval('date(2018, 6, 1)')).to eq(DateTime.new(2018, 6, 1))
    end

    it "evaluates relative days" do
      expect(eval('today() + 7')).to eq(now.to_date + 7.days)
    end

    it "evaluates not null checks" do
      issue1 = create(:issue, started_time: now)
      issue2 = create(:issue)
      expect(eval("has(startedTime)", [issue1, issue2])).to eq([issue1])
    end

    it "evaluates includes expressions" do
      issue1 = create(:issue, fields: { 'teams' => ['Android'] })
      issue2 = create(:issue, fields: { 'teams' => ['iOS'] })
      expect(eval("teams includes 'iOS'", [issue1, issue2])).to eq([issue2])
    end

    it "evaluates filter expressions" do
      board = create(:board)
      issue1 = create(:issue, key: 'ISS-101', board: board, fields: { 'teams' => ['Android'] })
      issue2 = create(:issue, key: 'ISS-102', board: board, fields: { 'teams' => ['iOS'] })
      board.filters.create(name: 'iOS', issue_keys: 'ISS-102', filter_type: :config_filter)

      results = eval("filter('iOS')", [issue1, issue2], board)

      expect(results).to eq([issue2])
    end

    it "evaluates not expressions on values" do
      expect(eval('not true')).to eq(false)
      expect(eval('not (1 = 2)')).to eq(true)
    end

    it "evaluates not expressions on issues" do
      board = create(:board)
      issue1 = create(:issue, key: 'ISS-101', board: board, fields: { 'teams' => ['Android'] })
      issue2 = create(:issue, key: 'ISS-102', board: board, fields: { 'teams' => ['iOS'] })
      board.filters.create(name: 'iOS', issue_keys: ['ISS-102'], filter_type: :config_filter)

      results = eval("not (teams includes 'iOS')", [issue1, issue2], board)

      expect(results).to eq([issue1])
    end

    it "evaluates binary operations on issue subexpressions" do
      issue1 = create(:issue, key: 'ISS-101', board: board, fields: { 'teams' => ['Android', 'iOS'] })
      issue2 = create(:issue, key: 'ISS-102', board: board, fields: { 'teams' => ['iOS'] })

      results = eval("(teams includes 'iOS') and not (teams includes 'Android')", [issue1, issue2], board)

      expect(results).to eq([issue2])
    end

    context "when given a sort clause" do
      let(:issue1) { create(:issue, fields: {'MyField' => 'A'}, key: 'ISSUE-101', board: board) }
      let(:issue2) { create(:issue, fields: {'MyField' => 'A'}, key: 'ISSUE-102', board: board) }
      let(:issue3) { create(:issue, fields: {'MyField' => 'B'}, board: board) }
      let(:issues) { [issue1, issue2, issue3] }

      it "sorts the return values by the sort clause, ascending" do
        results = eval("MyField = 'A' sort by key asc", issues, board)
        expect(results).to eq([issue1, issue2])
      end

      it "sorts the return values by the sort clause, descending" do
        results = eval("MyField = 'A' sort by key desc", issues, board)
        expect(results).to eq([issue2, issue1])
      end
    end

    context "when given a select statement" do
      let(:issue1) { create(:issue, fields: {'MyField' => 'A'}, key: 'ISSUE-101', status: 'Done', board: board) }
      let(:issue2) { create(:epic, fields: {'MyField' => 'A'}, key: 'ISSUE-102', board: board) }
      let(:issue3) { create(:project, fields: {'MyField' => 'B'}, board: board) }
      let(:issues) { [issue1, issue2, issue3] }

      it "selects the given issues" do
        query = <<~MQL
          select *
          from issues()
          where MyField = 'A' sort by key asc
        MQL
        results = eval(query, issues, board)
        expect(results).to eq([issue1, issue2])
      end

      it "selects the issues for the given status category" do
        query = <<~MQL
          select *
          from issues('Done')
          where MyField = 'A' sort by key asc
        MQL
        results = eval(query, issues, board)
        expect(results).to eq([issue1])
      end

      it "selects from epic data sources" do
        query = <<~MQL
          select *
          from epics()
        MQL
        results = eval(query, issues, board)
        expect(results).to eq([issue2])
      end

      it "selects from project data sources" do
        query = <<~MQL
          select *
          from projects()
        MQL
        results = eval(query, issues, board)
        expect(results).to eq([issue3])
      end
    end

    context "for custom project types" do
      let(:domain) { create(:domain, project_issue_type: 'Saga') }
      let(:board) { create(:board, domain: domain) }
      let(:issue) { create(:issue, issue_type: 'Saga', board: board) }

      it "renames the project data sources" do
        query = <<~MQL
          select *
          from sagas()
        MQL
        results = eval(query, [issue], board)
        expect(results).to eq([issue])
      end
    end
  end

  context "select expressions" do
    let(:issue1) { create(:issue, fields: {'MyField' => 'A'}, key: 'ISSUE-101', status: 'Done', board: board) }
    let(:issue2) { create(:epic, fields: {'MyField' => 'A'}, key: 'ISSUE-102', board: board) }
    let(:issue3) { create(:project, fields: {'MyField' => 'B'}, board: board) }

    it "selects by field" do
      query = <<~MQL
          select key, issuetype
          from issues()
          where MyField = 'A'
      MQL
      results = eval(query, [issue1, issue2, issue3])
      expect(results).to eq([
        ["ISSUE-101", "Story"],
        ["ISSUE-102", "Epic"]
      ])
    end

    it "selects complex expressions" do
      query = <<~MQL
          select (key + ' ' + issuetype)
          from issues()
          where MyField = 'A'
      MQL
      results = eval(query, [issue1, issue2, issue3])
      expect(results).to eq([
        ["ISSUE-101 Story"],
        ["ISSUE-102 Epic"]
      ])
    end
  end

  context "aggregate functions" do
    context "#count" do
      let(:issue1) { create(:issue, fields: {'MyField' => 'A'}, key: 'ISSUE-101', status: 'Done', board: board) }
      let(:issue2) { create(:epic, fields: {'MyField' => 'A'}, key: 'ISSUE-102', board: board) }
      let(:issue3) { create(:project, fields: {'MyField' => 'B'}, board: board) }

      it "aggregates by count" do
        query = <<~MQL
          select count()
          from issues()
          where MyField = 'A'
        MQL
        result = eval(query, [issue1, issue2, issue3])
        expect(result).to eq([2])
      end
    end
  end

  def eval(expr, issues = nil, board = nil)
    interpreter.eval(expr, board || create(:board), issues)
  end
end
