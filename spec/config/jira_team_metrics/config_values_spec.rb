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
      'bar' => { 'baz' => 'qux' },
      'foos' => [123],
      'bars' => [{ 'baz' => 'qux' }]
    }
  end

  context "#method_missing" do
    it "raises an error if the field isn't defined" do
      config = JiraTeamMetrics::ConfigValues.new(config_hash, YAML.load(schema), nil)
      expect { config.baz }.to raise_error(ArgumentError, 'Unknown config key: baz')
    end

    context "scalar values" do
      it "returns scalar values" do
        config = JiraTeamMetrics::ConfigValues.new(config_hash, YAML.load(schema), nil)
        expect(config.foo).to eq(123)
      end

      it "returns null for empty values" do
        config_hash.delete('foo')
        config = JiraTeamMetrics::ConfigValues.new(config_hash, YAML.load(schema), nil)
        expect(config.foo).to eq(nil)
      end
    end

    context "nested values" do
      it "returns nested values" do
        config = JiraTeamMetrics::ConfigValues.new(config_hash, YAML.load(schema), nil)
        expect(config.bar.baz).to eq('qux')
      end

      it "returns null for empty nested values" do
        config_hash['bar'].delete('baz')
        config = JiraTeamMetrics::ConfigValues.new(config_hash, YAML.load(schema), nil)
        expect(config.bar.baz).to eq(nil)
      end
    end

    context "array values" do
      it "returns nested values" do
        config = JiraTeamMetrics::ConfigValues.new(config_hash, YAML.load(schema), nil)
        expect(config.foos.to_a).to eq([123])
      end

      it "returns an empty array for empty values" do
        config_hash.delete('foos')
        config = JiraTeamMetrics::ConfigValues.new(config_hash, YAML.load(schema), nil)
        expect(config.foos.to_a).to eq([])
      end
    end

    context "when given a parent, for object values" do
      it "returns the parent value if none is defined" do
        parent = JiraTeamMetrics::Config.new({ 'foo' => 123 }, YAML.load(schema))
        config = JiraTeamMetrics::Config.new({}, YAML.load(schema), parent)
        expect(config.foo).to eq(123)
      end

      it "returns the child value if defined" do
        parent = JiraTeamMetrics::Config.new({ 'foo' => 123 }, YAML.load(schema))
        config = JiraTeamMetrics::Config.new({ 'foo' => 456 }, YAML.load(schema), parent)
        expect(config.foo).to eq(456)
      end

      it "returns the parent value for nested attributes if none are defined in the child config" do
        parent = JiraTeamMetrics::Config.new({ 'bar' => { 'baz' => 'qux' } }, YAML.load(schema))
        config = JiraTeamMetrics::Config.new({ 'bar' => {} }, YAML.load(schema), parent)
        expect(config.bar.baz).to eq('qux')
      end
    end

    context "when given a parent, for array values" do
      it "returns the parent value if none is defined" do
        parent = JiraTeamMetrics::Config.new({ 'bars' => [123] }, YAML.load(schema))
        config = JiraTeamMetrics::Config.new({}, YAML.load(schema), parent)
        expect(config.bars.to_a).to eq([123])
      end

      it "returns the child value if defined" do
        parent = JiraTeamMetrics::Config.new({ 'bars' => [123] }, YAML.load(schema))
        config = JiraTeamMetrics::Config.new({ 'bars' => [456] }, YAML.load(schema), parent)
        #expect(config.bars.to_a).to eq([456])
      end
    end

    context "custom types" do
      xit "returns custom types" do

      end
    end
  end
end
