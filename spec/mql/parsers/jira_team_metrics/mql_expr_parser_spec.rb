require 'rails_helper'

RSpec.describe JiraTeamMetrics::MqlExprParser do
  class TestExprParser < Parslet::Parser
    include JiraTeamMetrics::MqlLexer
    include JiraTeamMetrics::MqlOpParser
    include JiraTeamMetrics::MqlExprParser

    root :expression
  end

  let(:parser) { TestExprParser.new }

  it "parses integers" do
    expect(parser.parse('123')).to eq(int: '123')
  end

  it "parses booleans" do
    expect(parser.parse('true')).to eq(bool: 'true')
    expect(parser.parse('false')).to eq(bool: 'false')
  end

  it "parses fields" do
    expect(parser.parse('issuetype')).to eq(field: { ident: 'issuetype' })
  end

  it "parses field comparisons" do
    expect(parser.parse("issuetype = 'Bug'")).to eq({
        lhs: { field: { ident: 'issuetype' } },
        op: '=',
        rhs: { str: 'Bug' }
    })
  end

  it "parses arithmetic expressions" do
    expect(parser.parse('1 + 2')).to eq(lhs: { int: '1' }, op: '+', rhs: { int: '2' })
    expect(parser.parse('1 + 2 + 3')).to eq({
        lhs: { lhs: { int: '1' }, op: '+', rhs: { int: '2' } },
        op: '+',
        rhs: { int: '3' }
    })
    expect(parser.parse('1 + (2 + 3)')).to eq({
        lhs: { int: '1' },
        op: '+',
        rhs: { lhs: { int: '2' }, op: '+', rhs: { int: '3' } }
    })
  end

  it "parses multiplicative expressions" do
    expect(parser.parse('1 * 2')).to eq(lhs: { int: '1' }, op: '*', rhs: { int: '2' })
    expect(parser.parse('1 * 2 * 3')).to eq({
        lhs: { lhs: { int: '1' }, op: '*', rhs: { int: '2' } },
        op: '*',
        rhs: { int: '3' }
    })
    expect(parser.parse('1 * (2 * 3)')).to eq({
        lhs: { int: '1' },
        op: '*',
        rhs: { lhs: { int: '2' }, op: '*', rhs: { int: '3' } }
    })
  end

  it "parses general arithmetic expressions" do
    expect(parser.parse('1 + 2 * 3')).to eq({
        lhs: { int: '1' },
        op: '+',
        rhs: { lhs: { int: '2' }, op: '*', rhs: { int: '3' } }
    })
    expect(parser.parse('1 * 2 + 3')).to eq({
        lhs: { lhs: { int: '1' }, op: '*', rhs: { int: '2' } },
        op: '+',
        rhs: { int: '3' }
    })
  end

  it "parses boolean expressions" do
    expect(parser.parse('true and false')).to eq(lhs: { bool: 'true' }, op: 'and', rhs: { bool: 'false' })
    expect(parser.parse('true and true or false')).to eq({
        lhs: { lhs: { bool: 'true' }, op: 'and', rhs: { bool: 'true' } },
        op: 'or',
        rhs: { bool: 'false' }
    })
    expect(parser.parse('true and (true or false)')).to eq({
        lhs: { bool: 'true' },
        op: 'and',
        rhs: { lhs: { bool: 'true' }, op: 'or', rhs: { bool: 'false' } }
    })
  end

  it "parses function calls" do
    expect(parser.parse('fun()')).to eq({
      fun: { ident: 'fun', args: [] }
    })
    expect(parser.parse('fun(1)')).to eq({
      fun: { ident: 'fun', args: [{int: '1'}] }
    })
    expect(parser.parse("fun(1, 'foo')")).to eq({
      fun: { ident: 'fun', args: [{int: '1'}, {str: 'foo'}] }
    })
  end

  it "parses not expressions" do
    expect(parser.parse('not 1')).to eq({
      not: { int: '1' }
    })
  end
end
