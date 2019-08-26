require 'rails_helper'

class OpenStruct
  def deep_to_h
    to_h.transform_values do |v|
      case
        when v.is_a?(OpenStruct) then v.deep_to_h
        when v.is_a?(Array) then v.map{ |v| v.is_a?(OpenStruct) ? v.deep_to_h : v }
        else v
      end
    end
  end
end

RSpec.describe JiraTeamMetrics::Config do

  describe ".parse" do
    include JiraTeamMetrics::Config::ConfigParser::ClassMethods

    it "parses the schema when valid" do
      schema = { foo: string }
      config_hash = { foo: 'bar' }
      config = JiraTeamMetrics::Config::ConfigParser.parse(config_hash, schema)
      expect(config.foo).to eq('bar')
    end


    it "errors when schema not matched" do
      schema = { name: string }
      config_hash = { name: 123 }

      expect { JiraTeamMetrics::Config::ConfigParser.parse(config_hash, schema) }.
        to raise_error("Invalid type in config for field 'name': expected String but was Integer.")
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

    it "validates required fields" do
      expect {
        JiraTeamMetrics::Config::ConfigParser.parse_domain({
          name: 'My Domain'
        })
      }.to raise_error("Invalid type in config for field 'url': expected String but was NilClass.")
    end

    it "typechecks fields" do
      expect {
        JiraTeamMetrics::Config::ConfigParser.parse_domain({
          url: 'example.com',
          name: 123
        })
      }.to raise_error("Invalid type in config for field 'name': expected Optional<String> but was Integer.")
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
        predictive_scope: {
          board_id: 123,
          adjustments_field: 'Metrics Adjustments'
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
        predictive_scope: {
          board_id: 123,
          adjustments_field: 'Metrics Adjustments'
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
