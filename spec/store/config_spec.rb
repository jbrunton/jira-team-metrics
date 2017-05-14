require './stores/config'
require './stores/factory'
require 'byebug'

RSpec.describe Store::Config do
  let(:factory) { DummyFactory.new }
  let(:config_store) { factory.find_or_create('config') }
  let(:config) { config = Store::Config.new(factory) }

  context "set" do
    it "sets the value for the given param" do
      config.set('foo', 'bar')
      expect(config_store.inspect['foo']).to eq('bar')
    end

    it "sets nested values" do
      config.set('foo.bar', 'baz')
      expect(config_store.inspect['foo']).to eq('bar' => 'baz')
    end

    it "is non-destructive" do
      config.set('foo.x', 1)
      config.set('foo.y', 2)
      expect(config_store.inspect['foo']).to eq('x' => 1, 'y' => 2)
    end
  end

  context "get" do
    it "returns the value for the given param" do
      config.set('foo', 'bar')
      value = config.get('foo')
      expect(value).to eq('bar')
    end

    it "returns nested values" do
      config.set('foo.bar', 'baz')
      value = config.get('foo.bar')
      expect(value).to eq('baz')
    end
  end

  class DummyFactory < Store::Factory
    def create(name)
      DummyStore.new
    end
  end

  class DummyStore
    def initialize
      @hash = {}
    end

    def transaction(&block)
      @in_transaction = true
      value = yield
      @in_transaction = false
      value
    end

    def []=(*args)
      raise "Should be in transaction" if !@in_transaction
      @hash.send(:[]=, *args)
    end

    def [](*args)
      raise "Should be in transaction" if !@in_transaction
      @hash.send(:[], *args)
    end

    def inspect
      @hash
    end
  end
end
