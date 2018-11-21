require 'rails_helper'

RSpec.describe JiraTeamMetrics::MqlInterpreter do
  class TestParser < Parslet::Parser
    include JiraTeamMetrics::MqlLexer
    root :token
  end

  let(:parser) { TestParser.new }

  it "parses integers" do
    expect(parser.parse('123')).to eq(value: '123')
    expect(parser.parse('-123')).to eq(value: '-123')
  end

  it "parses identifiers" do
    [
        'camelCase',
        'snake_case',
        'ident_with_digits_123',
        'a'
    ].each do |identifier|
      expect(parser.parse(identifier)).to eq(identifier: identifier)
    end
  end

  it "fails on invalid identifiers" do
    expect{ parser.parse('123abc') }.to raise_error(Parslet::ParseFailed)
  end

  it "parses strings" do
    expect(parser.parse("'a string'")).to eq(value: 'a string')
  end

  it "fails on invalid strings" do
    expect{ parser.parse("'unterminated string") }.to raise_error(Parslet::ParseFailed)
  end
end
