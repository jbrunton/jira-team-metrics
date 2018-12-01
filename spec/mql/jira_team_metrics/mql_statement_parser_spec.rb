require 'rails_helper'

RSpec.describe JiraTeamMetrics::MqlStatementParser do
  let(:parser) { JiraTeamMetrics::MqlStatementParser.new }

  it "parses select-from statements" do
    expect(parser.parse('select 1 from issues()')).to eq({
      stmt: {
        select_exprs: [{ int: '1' }],
        from: { fun: { ident: 'issues', args: [] } },
        where: nil,
        sort: nil
      }
    })
  end

  it "parses select-from-sort statements" do
    expect(parser.parse('select 1 from issues() sort by 1 asc')).to eq({
      stmt: {
        select_exprs: [{ int: '1' }],
        from: { fun: { ident: 'issues', args: [] } },
        where: nil,
        sort: { expr: { int: '1' }, order: 'asc' }
      }
    })
  end

  it "parses select-from-where statements" do
    expect(parser.parse('select 1 from issues() where true')).to eq({
      stmt: {
        select_exprs: [{ int: '1' }],
        from: { fun: { ident: 'issues', args: [] } },
        where: { expr: { bool: 'true' } },
        sort: nil
      }
    })
  end

  it "parses select-from-where-sort statements" do
    expect(parser.parse('select 1 from issues() where true sort by false desc')).to eq({
      stmt: {
        select_exprs: [{ int: '1' }],
        from: { fun: { ident: 'issues', args: [] } },
        where: { expr: { bool: 'true' } },
        sort: { expr: { bool: 'false' }, order: 'desc' }
      }
    })
  end

  it "parses expression statements" do
    expect(parser.parse('startedTime - 7')).to eq({
      stmt: {
        expr: {
          lhs: { field: { ident: 'startedTime' } },
          op: '-',
          rhs: { int: '7' }
        }
      }
    })
  end

  xit "parses sort expressions" do
    expect(parser.parse("issuetype = 'Bug' sort by started_time asc")).to eq({
      sort: {
        expr: {
          lhs: { field: {ident: 'issuetype' } },
          op: '=',
          rhs: { str: 'Bug' }
        },
        sort_by: { ident: 'started_time' },
        order: 'asc'
      }
    })
    expect(parser.parse("true sort by 'My Field' asc")).to eq({
      sort: {
        expr: { bool: 'true' },
        sort_by: { str: 'My Field' },
        order: 'asc'
      }
    })
  end

  xit "parses sort statements" do

  end
end