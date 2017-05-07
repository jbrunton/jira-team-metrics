require './stores/config'
require './stores/factory'
require 'byebug'

RSpec.describe Store::Config do
  let(:factory) { DummyFactory.new }
  let(:config_store) { factory.find_or_create('config') }

  context "set" do
    it "sets the value for the given param" do
      config = Store::Config.new(factory)
      expect(config_store).to receive(:[]=).with('foo', 'bar')
      config.set('foo', 'bar')
    end
  end

  context "get" do
    it "returns the value for the given param" do
      config = Store::Config.new(factory)
      config.set('foo', 'bar')

      value = config.get('foo')

      expect(value).to eq('bar')
    end
  end

  class DummyFactory < Store::Factory
    def create(name)
      DummyStore.new
    end
  end

  class DummyStore < Hash
    def transaction(&block)
      @in_transaction = true
      value = yield
      @in_transaction = false
      value
    end

    def []=(*args)
      raise "Should be in transaction" if !@in_transaction
      super
    end

    def [](*args)
      raise "Should be in transaction" if !@in_transaction
      super
    end
  end
end
