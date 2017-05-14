module Store
  class Config
    def initialize(factory)
      @store = factory.find_or_create('config')
    end

    def get(path)
      @store.transaction do
        hash, name = traverse(path)
        hash[name]
      end
    end

    def set(path, value)
      @store.transaction do
        hash, name = traverse(path)
        hash[name] = value
      end
    end

    def self.instance
      @@config ||= Config.new(Factory.new)
    end

  private
    def traverse(path)
      hash = @store
      path_array = path.split('.')
      path_array.take(path_array.count - 1).each do |name|
        hash = hash[name] ||= {}
      end
      [hash, path_array.last]
    end
  end
end
