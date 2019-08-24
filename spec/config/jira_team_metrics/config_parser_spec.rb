require 'rails_helper'

class OpenStruct
  def deep_to_h
    to_h.transform_values do |v|
      v.is_a?(OpenStruct) ? v.deep_to_h : v
    end
  end
end

RSpec.describe JiraTeamMetrics::Config do
  let(:schema) do
    <<~SCHEMA
    type: "//rec"
    required:
      bar:
        type: "//str"
      foo:
        type: "//rec"
        required:
          bar: "//str"
        optional:
          baz: "//str"
    optional:
      foos:
        type: "//arr"
        contents: "//int"
      bars:
        type: "//arr"
        contents:
          type: "//rec"
          required:
            bar: "//str"
    SCHEMA
  end

  let(:config_hash) do
    {
      'foo' => {
        'bar' => 'baz'
      },
      'bar' => 'qux',
    }
  end

  describe ".parse_domain" do
    it "parses a domain config hash" do
      config = JiraTeamMetrics::ConfigParser.parse_domain({
        url: 'example.com',
        name: 'My Domain'
      })
      expect(config.url).to eq('example.com')
      expect(config.name).to eq('My Domain')
    end

    it "allows optional values" do
      config = JiraTeamMetrics::ConfigParser.parse_domain({
        url: 'example.com'
      })
      expect(config.url).to eq('example.com')
      expect(config.name).to eq(nil)
    end
  end

  describe ".parse_domain" do
    it "parses a domain config hash" do
      config = JiraTeamMetrics::ConfigParser.parse_domain({
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
        ]
      })
      expect(config.url).to eq('example.com')
      expect(config.name).to eq('My Domain')
      expect(config.epics.to_h).to eq({
        counting_strategy: 'once',
        link_missing: true
      })
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
        }
      })
    end
  end
end
