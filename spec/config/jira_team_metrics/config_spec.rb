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
          foos:
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

  context "#get" do
    it "returns the value for the key" do
      config = JiraTeamMetrics::Config.new(config_hash, YAML.load(schema))
      expect(config.get('bar')).to eq('qux')
    end

    it "returns the value for a nested key" do
      config = JiraTeamMetrics::Config.new(config_hash, YAML.load(schema))
      expect(config.get('foo.bar')).to eq('baz')
    end

    it "returns a default value if none exists" do
      config = JiraTeamMetrics::Config.new(config_hash, YAML.load(schema))
      expect(config.get('foo.baz', 'quux')).to eq('quux')
    end

    it "checks the parent config if given" do
      parent = JiraTeamMetrics::Config.new({ 'foo' => 'bar' }, YAML.load(schema))
      config = JiraTeamMetrics::Config.new({}, YAML.load(schema), parent)
      expect(config.get('foo')).to eq('bar')
    end
  end

  context "#method_missing" do
    it "returns scalar values" do
      config = JiraTeamMetrics::Config.new(config_hash, YAML.load(schema))
      expect(config.bar).to eq('qux')
    end

    it "returns nested values" do
      config = JiraTeamMetrics::Config.new(config_hash, YAML.load(schema))
      expect(config.foo.bar).to eq('baz')
    end

    it "returns null values when optional" do
      config = JiraTeamMetrics::Config.new(config_hash, YAML.load(schema))
      expect(config.foo.baz).to eq(nil)
    end

    it "returns array values" do
      config = JiraTeamMetrics::Config.new(config_hash, YAML.load(schema))
      expect(config.foo.foos.to_a).to eq([])
    end
  end
end
