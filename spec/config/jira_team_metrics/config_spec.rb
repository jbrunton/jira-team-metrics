require 'rails_helper'

RSpec.describe JiraTeamMetrics::Config do
  let(:config_hash) do
    {
      'foo' => 'bar'
    }
  end

  let(:schema) do
    <<~SCHEMA
    type: "//rec"
    optional:
      foo:
        type: "//str"
    SCHEMA
  end

  it "initializes #config_hash" do
    config = JiraTeamMetrics::Config.new(config_hash, YAML.load(schema))
    expect(config.config_hash).to eq(config_hash)
  end

  context "#validate" do
    it "validates a well formed config" do
      config = JiraTeamMetrics::Config.new(config_hash, YAML.load(schema))
      expect { config.validate }.not_to raise_error
    end

    it "validates the top level fields" do
      config_hash['unexpected_field'] = 'foo'
      config = JiraTeamMetrics::Config.new(config_hash, YAML.load(schema))
      expect { config.validate }.to raise_error(Rx::ValidationError, /Hash had extra keys/)
    end
  end
end
