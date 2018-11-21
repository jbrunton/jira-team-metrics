require 'rails_helper'

RSpec.describe JiraTeamMetrics::MqlExprParser do
  let(:parser) { JiraTeamMetrics::MqlExprParser.new }

  it "parses integers" do
    expect(parser.parse('123')).to eq(value: '123')
  end

  it "parses additive expressions" do
    expect(parser.parse('1 + 2')).to eq(lhs: { value: '1' }, op: '+', rhs: { value: '2' })
    expect(parser.parse('1 + 2 + 3')).to eq({
        lhs: { value: '1' },
        op: '+',
        rhs: { lhs: { value: '2' }, op: '+', rhs: { value: '3' } }
    })
    expect(parser.parse('(1 + 2) + 3')).to eq({
        lhs: { lhs: { value: '1' }, op: '+', rhs: { value: '2' } },
        op: '+',
        rhs: { value: '3' }
    })
  end
end
