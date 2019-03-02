require 'rails_helper'

RSpec.describe JiraTeamMetrics::ConfigValues do
  let(:schema) do
    <<~SCHEMA
    type: "//rec"
    optional:
      foo:
        type: "//int"
      bar:
        type: "//rec"
        optional:
          baz: "//str"
      foos:
        type: "//arr"
        contents: "//int"
      bars:
        type: "//arr"
        contents:
          type: "//rec"
          optional:
            baz: "//str"
    SCHEMA
  end

  let(:config_hash) do
    {
      'foo' => 123,
      'bar' => { 'baz' => 'qux' }
    }
  end

  context "#method_missing" do
    it "raises an error if the field isn't defined" do
      config = JiraTeamMetrics::Config.new(config_hash, YAML.load(schema))
      expect { config.baz }.to raise_error(ArgumentError, 'Unknown config key: baz')
    end

    context "scalar values" do
      it "returns scalar values" do
        config = JiraTeamMetrics::Config.new(config_hash, YAML.load(schema))
        expect(config.foo).to eq(123)
      end

      it "returns null for empty values" do
        config_hash.delete('foo')
        config = JiraTeamMetrics::Config.new(config_hash, YAML.load(schema))
        expect(config.foo).to eq(nil)
      end
    end

    context "nested values" do
      it "returns nested values" do
        config = JiraTeamMetrics::Config.new(config_hash, YAML.load(schema))
        expect(config.bar.baz).to eq('qux')
      end

      it "returns null for empty nested values" do
        config_hash['bar'].delete('baz')
        config = JiraTeamMetrics::Config.new(config_hash, YAML.load(schema))
        expect(config.bar.baz).to eq(nil)
      end
    end
  end
end
