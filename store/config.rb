module Store
  class Config
    def initialize(store)
      @store = store
    end

    def get(param)
      @store.transaction { @store[param] }
    end

    def set(param, value)
      @store.transaction { @store[param] = value }
    end

    def self.instance
      @@config ||= Config.new(YAML::Store.new('data/config.yml'))
    end
  end
end
