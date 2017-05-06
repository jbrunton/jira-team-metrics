module Store
  class Boards
    def initialize(store)
      @store = store
    end

    def boards
      @store.transaction { @store['boards'] }
    end

    def last_updated
      @store.transaction { @store['last_updated'] }
    end

    def update(boards)
      @store.transaction do
        @store['boards'] = boards
        @store['last_updated'] = Time.now
      end
    end

    def self.instance
      @@config ||= Boards.new(YAML::Store.new('data/boards.yml'))
    end
  end
end
