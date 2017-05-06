require './store/factory'

module Store
  class Boards
    def initialize(factory)
      @store = factory.find_or_create('boards')
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
      @@boards ||= Boards.new(Factory.instance)
    end
  end
end
