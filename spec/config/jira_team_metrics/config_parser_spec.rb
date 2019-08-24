require 'rails_helper'

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
end
