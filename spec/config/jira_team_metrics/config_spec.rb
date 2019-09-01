require 'rails_helper'

RSpec.describe JiraTeamMetrics::Config do
  include JiraTeamMetrics::Config::ConfigParser::ClassMethods

  let(:schema) do
    hash({
      bar: string,
      foo: {
        bar: string,
        baz: opt(string)
      },
      foos: opt_array_of(int),
      bars: opt_array_of({
        bar: string
      })
    })
  end

  let(:config_object) do
    OpenStruct.new({
      'foo' => OpenStruct.new({
        'bar' => 'baz'
      }),
      'bar' => 'qux'
    })
  end

  it "initializes #config_object" do
    config = JiraTeamMetrics::Config::Config.new(config_object, schema)
    expect(config.config_object).to eq(config_object)
  end

  context "#validate" do
    it "validates a well formed config" do
      config = JiraTeamMetrics::Config::Config.new(config_object, schema)
      expect { config.validate }.not_to raise_error
    end

    it "validates the top level fields" do
      config_object['unexpected_field'] = 'foo'
      config = JiraTeamMetrics::Config::Config.new(config_object, schema)
      expect { config.validate }.to raise_error(Rx::ValidationError, /Hash had extra keys/)
    end
  end

  context "#method_missing" do
    it "returns scalar values" do
      config = JiraTeamMetrics::Config::Config.new(config_object, schema)
      expect(config.bar).to eq('qux')
    end

    it "returns nested values" do
      config = JiraTeamMetrics::Config::Config.new(config_object, schema)
      expect(config.foo.bar).to eq('baz')
    end

    it "returns null values when optional" do
      config = JiraTeamMetrics::Config::Config.new(config_object, schema)
      expect(config.foo.baz).to eq(nil)
    end

    it "returns default values when missing" do
      config = JiraTeamMetrics::Config::Config.new(config_object, schema)
      expect(config.foo.baz(123)).to eq(123)
    end

    it "checks the parent config when given" do
      parent = JiraTeamMetrics::Config::Config.new({ 'bar' => 'baz' }, schema)
      config = JiraTeamMetrics::Config::Config.new({}, schema, parent)
      expect(config.bar).to eq('baz')
    end

    it "returns empty array for missing array values" do
      config = JiraTeamMetrics::Config::Config.new(config_object, schema)
      expect(config.foos.to_a).to eq([])
    end

    it "returns array scalar values" do
      config = JiraTeamMetrics::Config::Config.new({ 'foos' => [1, 2] }, schema)
      expect(config.foos[0]).to eq(1)
    end

    it "returns array rec values" do
      config = JiraTeamMetrics::Config::Config.new({ 'bars' => [{ 'bar' => 2 }] }, schema)
      expect(config.bars[0].bar).to eq(2)
    end

    it "returns arrays with array contents" do
      schema = <<~SCHEMA
      type: "//rec"
      required:
        foos:
          type: "//arr"
          contents:
            type: "//arr"
            contents:
              type: "//rec"
              required:
                bar: "//int"
      SCHEMA
      config = JiraTeamMetrics::Config::Config.new({ 'foos' => [[{ 'bar' => 1}]] }, schema)
      expect(config.foos[0][0].bar).to eq(1)
    end
  end
end
