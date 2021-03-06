require 'rails_helper'

RSpec.describe JiraTeamMetrics::Config do

  describe ".parse" do
    include JiraTeamMetrics::Config::ConfigParser::ClassMethods

    it "parses the schema when valid" do
      schema = { foo: string }
      config_hash = { foo: 'bar' }
      config = JiraTeamMetrics::Config::ConfigParser.parse(config_hash, schema)
      expect(config.foo).to eq('bar')
    end

    it "recursively parses hash elements" do
      schema = { foo: { bar: string, baz: opt(string) } }
      config_hash = { foo: { bar: 'bar' } }
      config = JiraTeamMetrics::Config::ConfigParser.parse(config_hash, schema)
      expect(config.foo.bar).to eq('bar')
      expect(config.foo.baz).to eq(nil)
    end

    it "recursively parses array elements" do
      schema = { foos: array_of({ bar: string, baz: opt(string) }) }
      config_hash = { foos: [{ bar: 'bar' }] }
      config = JiraTeamMetrics::Config::ConfigParser.parse(config_hash, schema)
      expect(config.foos[0].bar).to eq('bar')
      expect(config.foos[0].baz).to eq(nil)
    end
  end

  describe ".parse_domain" do
    let(:full_config_hash) do
      {
        url: 'example.com',
        name: 'My Domain',
        fields: ['Developer', 'Tester'],
        projects: {
          issue_type: 'Delivery',
          inward_link_type: 'includes',
          outward_link_type: 'included in'
        },
        epics: {
          counting_strategy: 'once',
          link_missing: true
        },
        boards: [
          {
            board_id: 123,
            config_file: 'my/config/file.yaml'
          }
        ],
        teams: [
          {
            name: 'My Team',
            short_name: 'my'
          }
        ],
        reports: {
          epics: {
            backing_query: 'epics backing query',
            card_layout: {
              fields: ['Developer']
            },
            sections: [
              {
                title: 'Backlog',
                mql: 'query',
                collapsed: true,
                min: 3,
                max: 8
              }
            ]
          },
          projects: {
            backing_query: 'projects backing query',
            card_layout: {
              fields: ['Developer']
            },
            sections: [
              {
                title: 'Backlog',
                mql: 'query',
                collapsed: true
              }
            ]
          },
          scatterplot: {
            default_query: 'default scatterplot query'
          },
          throughput: {
            default_query: 'default throughput query'
          },
          aging_wip: {
            default_query: 'default aging_wip query',
            fields: ['My Field']
          },
          custom_reports: [
            name: 'My Report',
            query: 'my report query',
            description: 'my report description'
          ]
        }
      }
    end

    it "parses a domain config hash into an OpenStruct" do
      config = JiraTeamMetrics::Config::ConfigParser.parse_domain({
        url: 'example.com',
        name: 'My Domain',
        projects: {
          issue_type: 'Delivery',
          inward_link_type: 'includes',
          outward_link_type: 'included in'
        }
      })
      expect(config.url).to eq('example.com')
      expect(config.name).to eq('My Domain')
    end

    it "parses nested array objects into an OpenStruct" do
      config = JiraTeamMetrics::Config::ConfigParser.parse_domain({
        url: 'example.com',
        projects: {
          issue_type: 'Delivery',
          inward_link_type: 'includes',
          outward_link_type: 'included in'
        },
        reports: {
          epics: {
            sections: [
              {
                title: 'Backlog',
                mql: 'query'
              }
            ]
          }
        }
      })
      expect(config.reports.epics.sections[0].title).to eq('Backlog')
    end

    it "parses a full domain config hash" do
      config = JiraTeamMetrics::Config::ConfigParser.parse_domain(full_config_hash)
      expect(config.deep_to_h).to eq(full_config_hash)
    end

    it "allows optional values" do
      config = JiraTeamMetrics::Config::ConfigParser.parse_domain({
        url: 'example.com',
        projects: {
          issue_type: 'Delivery',
          inward_link_type: 'includes',
          outward_link_type: 'included in'
        }
      })
      expect(config.deep_to_h).to eq({
        url: 'example.com',
        name: nil,
        fields: [],
        projects: {
          issue_type: 'Delivery',
          inward_link_type: 'includes',
          outward_link_type: 'included in'
        },
        epics: {
          counting_strategy: nil,
          link_missing: nil
        },
        boards: [],
        teams: [],
        reports: {
          epics: {
            backing_query: nil,
            card_layout: {
              fields: []
            },
            sections: []
          },
          projects: {
            backing_query: nil,
            card_layout: {
              fields: []
            },
            sections: []
          },
          scatterplot: {
            default_query: nil
          },
          throughput: {
            default_query: nil
          },
          aging_wip: {
            default_query: nil,
            fields: []
          },
          custom_reports: []
        }
      })
    end
  end

  describe ".parse_board" do
    let(:full_config_hash) do
      {
        default_query: 'default query',
        epics: {
          counting_strategy: 'once',
          link_missing: true
        },
        filters: [
          {
            name: 'my filter',
            type: 'mql',
            query: 'filter query'
          }
        ],
        predictive_scope: {
          board_id: 123,
          adjustments_field: 'Metrics Adjustments'
        },
        timesheets: {
          additional_columns: ['Capex Budget'],
          reporting_period: {
            day_of_week: 1,
            duration: {
              days: 7
            }
          }
        },
        rolling_window: {
          days: 7
        },
        sync: {
          months: 6
        },
        reports: {
          epics: {
            backing_query: 'epics backing query',
            card_layout: {
              fields: ['Developer']
            },
            sections: [
              {
                title: 'Backlog',
                mql: 'query',
                collapsed: true,
                min: 3,
                max: 8
              }
            ]
          },
          projects: {
            backing_query: 'projects backing query',
            card_layout: {
              fields: ['Developer']
            },
            sections: [
              {
                title: 'Backlog',
                mql: 'query',
                collapsed: true
              }
            ]
          },
          scatterplot: {
            default_query: 'default scatterplot query'
          },
          throughput: {
            default_query: 'default throughput query'
          },
          aging_wip: {
            default_query: 'default aging_wip query',
            fields: ['My Field']
          },
          custom_reports: [
            name: 'My Report',
            query: 'my report query',
            description: 'my report description'
          ]
        }
      }
    end

    it "parses a board config hash into an OpenStruct" do
      config = JiraTeamMetrics::Config::ConfigParser.parse_board({
        predictive_scope: {
          board_id: 123,
          adjustments_field: 'Metrics Adjustments'
        }
      }, {})
      expect(config.predictive_scope.board_id).to eq(123)
      expect(config.predictive_scope.adjustments_field).to eq('Metrics Adjustments')
    end

    it "parses a full board config hash" do
      config = JiraTeamMetrics::Config::ConfigParser.parse_board(full_config_hash, {})
      expect(config.deep_to_h).to eq(full_config_hash)
    end

    it "allows null configs" do
      config = JiraTeamMetrics::Config::ConfigParser.parse_board(nil, {})
      expect(config.deep_to_h).to eq({
        default_query: nil,
        epics: {
          counting_strategy: nil,
          link_missing: nil
        },
        filters: [],
        predictive_scope: {
          board_id: nil,
          adjustments_field: nil
        },
        rolling_window: {
          days: nil
        },
        sync: {
          months: nil
        },
        timesheets: {
          additional_columns: [],
          reporting_period: {
            day_of_week: nil,
            duration: {
              days: nil
            }
          }
        },
        reports: {
          epics: {
            backing_query: nil,
            card_layout: {
              fields: []
            },
            sections: []
          },
          projects: {
            backing_query: nil,
            card_layout: {
              fields: []
            },
            sections: []
          },
          scatterplot: {
            default_query: nil
          },
          throughput: {
            default_query: nil
          },
          aging_wip: {
            default_query: nil,
            fields: []
          },
          custom_reports: []
        }
      })
    end

    it "allows optional values" do
      config = JiraTeamMetrics::Config::ConfigParser.parse_board({
        predictive_scope: {
          board_id: 123,
          adjustments_field: 'Metrics Adjustments'
        }
      }, {})
      expect(config.deep_to_h).to eq({
        default_query: nil,
        epics: {
          counting_strategy: nil,
          link_missing: nil
        },
        filters: [],
        predictive_scope: {
          board_id: 123,
          adjustments_field: 'Metrics Adjustments'
        },
        rolling_window: {
          days: nil
        },
        sync: {
          months: nil
        },
        timesheets: {
          additional_columns: [],
          reporting_period: {
            day_of_week: nil,
            duration: {
              days: nil
            }
          }
        },
        reports: {
          epics: {
            backing_query: nil,
            card_layout: {
              fields: []
            },
            sections: []
          },
          projects: {
            backing_query: nil,
            card_layout: {
              fields: []
            },
            sections: []
          },
          scatterplot: {
            default_query: nil
          },
          throughput: {
            default_query: nil
          },
          aging_wip: {
            default_query: nil,
            fields: []
          },
          custom_reports: []
        }
      })
    end

    it "inherits domain values" do
      config = JiraTeamMetrics::Config::ConfigParser.parse_board({
        predictive_scope: {
          board_id: 123,
          adjustments_field: 'Metrics Adjustments'
        }
      }, {
        url: 'example.com',
        reports: {
          scatterplot: {
            default_query: 'domain query'
          }
        }
      })
      expect(config.reports.scatterplot.default_query).to eq('domain query')
    end

    it "overrides domain values" do
      config = JiraTeamMetrics::Config::ConfigParser.parse_board({
        predictive_scope: {
          board_id: 123,
          adjustments_field: 'Metrics Adjustments'
        },
        reports: {
          scatterplot: {
            default_query: 'board query'
          }
        }
      }, {
        url: 'example.com',
        reports: {
          scatterplot: {
            default_query: 'domain query'
          }
        }
      })
      expect(config.reports.scatterplot.default_query).to eq('board query')
    end
  end
end
