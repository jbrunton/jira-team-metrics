require 'rails_helper'

RSpec.describe JiraTeamMetrics::MqlStatementParser do
  let(:parser) { JiraTeamMetrics::MqlStatementParser.new }

  it "parses select-from statements" do
    expect(parser.parse('select 1 from issues()')).to eq({
      stmt: {
        select: {
          select_clause: {
            exprs: [{ int: '1' }]
          }
        },
        from: {
          from_clause: {
            data_source: {
              fun: { ident: 'issues', args: [] }
            }
          }
        },
        where: nil,
        group: nil,
        sort: nil
      }
    })
  end

  it "parses select-from-sort statements" do
    expect(parser.parse('select 1 from issues() sort by 1 asc')).to eq({
      stmt: {
        select: {
          select_clause: {
            exprs: [{ int: '1' }]
          }
        },
        from: {
          from_clause: {
            data_source: {
              fun: { ident: 'issues', args: [] }
            }
          },
        },
        where: nil,
        group: nil,
        sort: {
          sort_clause: {
            expr: { int: '1' }, order: 'asc'
          }
        }
      }
    })
  end

  it "parses select-from-where statements" do
    expect(parser.parse('select 1 from issues() where true')).to eq({
      stmt: {
        select: {
          select_clause: {
            exprs: [{ int: '1' }]
          },
        },
        from: {
          from_clause: {
            data_source: {
              fun: { ident: 'issues', args: [] }
            }
          },
        },
        where: {
          where_clause: {
            expr: { bool: 'true' }
          },
        },
        group: nil,
        sort: nil
      }
    })
  end

  it "parses select-from-where-sort statements" do
    expect(parser.parse('select 1 from issues() where true sort by false desc')).to eq({
      stmt: {
        select: {
          select_clause: {
            exprs: [{ int: '1' }]
          },
        },
        from: {
          from_clause: {
            data_source: {
              fun: { ident: 'issues', args: [] }
            }
          },
        },
        where: {
          where_clause: {
            expr: { bool: 'true' }
          }
        },
        group: nil,
        sort: {
          sort_clause: {
            expr: { bool: 'false' },
            order: 'desc'
          }
        }
      }
    })
  end

  it "parses group-by statements" do
    expect(parser.parse('select key, count() from issues() group by key')).to eq({
      stmt: {
        select: {
          select_clause: {
            exprs: [
              { field: { ident: 'key' } },
              { fun: { ident: 'count', args: [] } }
            ]
          }
        },
        from: {
          from_clause: {
            data_source: {
              fun: { ident: 'issues', args: [] }
            }
          }
        },
        where: nil,
        group: {
          group_clause: {
            expr: { field: { ident: 'key' } }
          }
        },
        sort: nil
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
        },
        sort: nil
      }
    })
  end

  it "parses sort-expression statements" do
    expect(parser.parse("issuetype = 'Bug' sort by createdTime")).to eq({
      stmt: {
        expr: {
          lhs: { field: { ident: 'issuetype' } },
          op: '=',
          rhs: { str: 'Bug' } },
        sort: {
          sort_clause:
            {
              expr: { field: { ident: 'createdTime' } },
              order: nil
            }
        }
      }
    })
  end
end