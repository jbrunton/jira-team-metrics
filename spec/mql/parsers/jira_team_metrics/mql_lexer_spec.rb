require 'rails_helper'

RSpec.describe JiraTeamMetrics::MqlLexer do
  class TestLexer < Parslet::Parser
    include JiraTeamMetrics::MqlLexer
    rule(:token) { int | bool | ident | string }
    root :token
  end

  let(:parser) { TestLexer.new }


  it "parses integers" do
    expect(parser.parse('123')).to eq(int: '123')
    expect(parser.parse('-123')).to eq(int: '-123')
  end

  it "parses booleans" do
    expect(parser.parse('true')).to eq(bool: 'true')
    expect(parser.parse('false')).to eq(bool: 'false')
  end

  it "parses identifiers" do
    [
        'camelCase',
        'snake_case',
        'ident_with_digits_123',
        'a'
    ].each do |identifier|
      expect(parser.parse(identifier)).to eq(ident: identifier)
    end
  end

  it "fails on invalid identifiers" do
    expect{ parser.parse('123abc') }.to raise_error(Parslet::ParseFailed)
  end

  it "parses strings" do
    expect(parser.parse("'a string'")).to eq(str: 'a string')
  end

  it "fails on invalid strings" do
    expect{ parser.parse("'unterminated string") }.to raise_error(Parslet::ParseFailed)
  end
end
