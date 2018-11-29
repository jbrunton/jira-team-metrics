require 'rails_helper'

RSpec.describe JiraTeamMetrics::MqlStatementParser do
  let(:parser) { JiraTeamMetrics::MqlStatementParser.new }

  it "parses sort expressions" do
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
end