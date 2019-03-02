require 'rails_helper'

RSpec.describe JiraTeamMetrics::ConfigValues do
  let(:scalar_arr_schema) do
    <<~SCHEMA
    type: "//arr"
    contents: "//int"
    SCHEMA
  end

  let(:hash_arr_schema) do
    <<~SCHEMA
    type: "//arr"
    contents:
      type: "//rec"
      optional:
        foo:
          type: "//int"
        bar:
          type: "//rec"
          optional:
            baz: "//str"
    SCHEMA
  end

  let(:array_arr_schema) do
    <<~SCHEMA
    type: "//arr"
    contents:
      type: "//arr"
      contents:
        type: "//rec"
        optional:
          foo:
            type: "//int"
    SCHEMA
  end

  let(:scalar_config_arr) { [123] }

  let(:hash_config_arr) do
    [{
      'foo' => 123,
      'bar' => { 'baz' => 'qux' }
    }]
  end

  let(:array_config_arr) do
    [[{ 'foo' => 123 }]]
  end

  context "#each" do
    it "implements #each and the enumerable module" do
      config = JiraTeamMetrics::ConfigArray.new(scalar_config_arr, YAML.load(scalar_arr_schema))
      expect(config.to_a).to eq([123])
      expect(config.map{ |x| x * 2 }).to eq([246])
    end
  end

  context "[]" do
    it "returns scalar values" do
      config = JiraTeamMetrics::ConfigArray.new(scalar_config_arr, YAML.load(scalar_arr_schema))
      expect(config[0]).to eq(123)
    end

    it "returns hash values" do
      config = JiraTeamMetrics::ConfigArray.new(hash_config_arr, YAML.load(hash_arr_schema))
      expect(config[0].foo).to eq(123)
      expect(config[0].bar.baz).to eq('qux')
    end

    it "returns array values" do
      config = JiraTeamMetrics::ConfigArray.new(array_config_arr, YAML.load(array_arr_schema))
      expect(config[0][0].foo).to eq(123)
    end
  end

  #   it "raises an error if the field isn't defined" do
  #     config = JiraTeamMetrics::Config.new(config_hash, YAML.load(schema))
  #     expect { config.baz }.to raise_error(ArgumentError, 'Unknown config key: baz')
  #   end
  #
  #   context "scalar values" do
  #     it "returns scalar values" do
  #       config = JiraTeamMetrics::Config.new(config_hash, YAML.load(schema))
  #       expect(config.foo).to eq(123)
  #     end
  #
  #     it "returns null for empty values" do
  #       config_hash.delete('foo')
  #       config = JiraTeamMetrics::Config.new(config_hash, YAML.load(schema))
  #       expect(config.foo).to eq(nil)
  #     end
  #   end
  #
  #   context "nested values" do
  #     it "returns nested values" do
  #       config = JiraTeamMetrics::Config.new(config_hash, YAML.load(schema))
  #       expect(config.bar.baz).to eq('qux')
  #     end
  #
  #     it "returns null for empty nested values" do
  #       config_hash['bar'].delete('baz')
  #       config = JiraTeamMetrics::Config.new(config_hash, YAML.load(schema))
  #       expect(config.bar.baz).to eq(nil)
  #     end
  #   end
  #
  #   context "array values" do
  #     it "returns nested values" do
  #       config = JiraTeamMetrics::Config.new(config_hash, YAML.load(schema))
  #       expect(config.foos.to_a).to eq([123])
  #     end
  #
  #     it "returns an empty array for empty values" do
  #       config_hash.delete('foos')
  #       config = JiraTeamMetrics::Config.new(config_hash, YAML.load(schema))
  #       expect(config.foos.to_a).to eq([])
  #     end
  #   end
  #
  #   context "custom types" do
  #     xit "returns custom types" do
  #
  #     end
  #   end
  # end
end
