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
  describe ".parse_domain" do
    let(:full_config_hash) do
      {
        url: 'example.com',
        name: 'My Domain',
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
          scatterplot: {
            default_query: 'default scatterplot query'
          }
        }
      }
    end

    it "parses a domain config hash into an OpenStruct" do
      config = JiraTeamMetrics::ConfigParser.parse_domain({
        url: 'example.com',
        name: 'My Domain'
      })
      expect(config.url).to eq('example.com')
      expect(config.name).to eq('My Domain')
    end

    it "parses a full domain config hash" do
      config = JiraTeamMetrics::ConfigParser.parse_domain(full_config_hash)
      expect(config.deep_to_h).to eq(full_config_hash)
    end

    it "allows optional values" do
      config = JiraTeamMetrics::ConfigParser.parse_domain({
        url: 'example.com'
      })
      expect(config.deep_to_h).to eq({
        url: 'example.com',
        name: nil,
        epics: {
          counting_strategy: nil,
          link_missing: nil
        },
        boards: [],
        teams: [],
        reports: {
          scatterplot: {
            default_query: nil
          }
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
        predictive_scope: {
          board_id: 123,
          adjustments_field: 'Metrics Adjustments'
        },
        reports: {
          scatterplot: {
            default_query: 'default scatterplot query'
          }
        }
      }
    end

    it "parses a board config hash into an OpenStruct" do
      config = JiraTeamMetrics::ConfigParser.parse_board({
        predictive_scope: {
          board_id: 123,
          adjustments_field: 'Metrics Adjustments'
        }
      })
      expect(config.predictive_scope.board_id).to eq(123)
      expect(config.predictive_scope.adjustments_field).to eq('Metrics Adjustments')
    end

    it "parses a full board config hash" do
      config = JiraTeamMetrics::ConfigParser.parse_board(full_config_hash)
      expect(config.deep_to_h).to eq(full_config_hash)
    end

    it "allows optional values" do
      config = JiraTeamMetrics::ConfigParser.parse_board({
        predictive_scope: {
          board_id: 123,
          adjustments_field: 'Metrics Adjustments'
        }
      })
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
          scatterplot: {
            default_query: nil
          }
        }
      })
    end
  end
end
