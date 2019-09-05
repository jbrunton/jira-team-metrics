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
      expect { config.validate }.to raise_error(TypeError, "Unexpected field 'unexpected_field' found in hash")
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

    it "returns empty array for missing array values" do
      config = JiraTeamMetrics::Config::Config.new(config_object, schema)
      expect(config.foos.to_a).to eq([])
    end
  end
end
