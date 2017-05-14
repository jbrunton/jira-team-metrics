module Store
  class Factory
    def initialize
      @stores = {}
    end
    
    def create(name)
      YAML::Store.new("cache/#{name}.yml")
    end

    def find_or_create(name)
      @stores[name] ||= create(name)
    end

    def self.instance
      @@instance ||= Factory.new
    end
  end
end
