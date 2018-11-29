require 'rails_helper'

RSpec.describe JiraTeamMetrics::MqlOpParser do
  class TestOpParser < Parslet::Parser
    include JiraTeamMetrics::MqlLexer
    include JiraTeamMetrics::MqlOpParser
    rule(:expression) { binop | primary_expression }
    rule(:primary_expression) { int }
    root :expression
  end

  let(:parser) { TestOpParser.new }

  it "parses operators" do
    ['+', '-', '*', '/', '<', '>', '<=', '>=', 'and', 'or'].each do |op|
      expect(parser.parse("1 #{op} 2")).to eq({
        lhs: { int: '1' }, op: op, rhs: { int: '2' }
      })
    end
  end

  it "parses arithmetic operators with precedence" do
    expect(parser.parse('1 + 2 * 3')).to eq({
      lhs: { int: '1' },
      op: '+',
      rhs: { lhs: { int: '2' }, op: '*', rhs: { int: '3' } }
    })
    expect(parser.parse('1 / 2 - 3')).to eq({
      lhs: { lhs: { int: '1' }, op: '/', rhs: { int: '2' } },
      op: '-',
      rhs: { int: '3' }
    })
  end

  it "parses inequalities with precedence" do
    expect(parser.parse('1 < 2 = 3 > 2')).to eq({
      lhs: { lhs: { int: '1' }, op: '<', rhs: { int: '2' } },
      op: '=',
      rhs: { lhs: { int: '3' }, op: '>', rhs: { int: '2' } }
    })
    expect(parser.parse('1 <= 2 = 3 >= 2')).to eq({
      lhs: { lhs: { int: '1' }, op: '<=', rhs: { int: '2' } },
      op: '=',
      rhs: { lhs: { int: '3' }, op: '>=', rhs: { int: '2' } }
    })
  end

  it "parses boolean operators with precedence" do
    expect(parser.parse('1 < 2 and 2 = 2')).to eq({
      lhs: { lhs: { int: '1' }, op: '<', rhs: { int: '2' } },
      op: 'and',
      rhs: { lhs: { int: '2' }, op: '=', rhs: { int: '2' } }
    })
    expect(parser.parse('1 and 2 or 3 >= 2')).to eq({
      lhs: { lhs: { int: '1' }, op: 'and', rhs: { int: '2' } },
      op: 'or',
      rhs: { lhs: { int: '3' }, op: '>=', rhs: { int: '2' } }
    })
  end
end