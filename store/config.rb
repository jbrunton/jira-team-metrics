module Store
  class Config
    def initialize(factory)
      @store = factory.find_or_create('config')
    end

    def get(param)
      @store.transaction { @store[param] }
    end

    def set(param, value)
      @store.transaction { @store[param] = value }
    end

    def self.instance
      @@config ||= Config.new(Factory.new)
    end
  end
end
