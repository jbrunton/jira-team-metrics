module Store
  class Boards
    def initialize(factory)
      @factory = factory
    end

    def all
      boards_store
        .transaction { boards_store['boards'] }
        .map { |_, attrs| RapidBoard.new(attrs) }
    end

    def last_updated
      boards_store.transaction { boards_store['last_updated'] }
    end

    def update(boards)
      boards_store.transaction do
        boards_store['boards'] = boards.map { |board| [board.id, board.to_h] }
        boards_store['last_updated'] = Time.now
      end
    end

    # def board(id)
    #   store = @factory.find_or_create("board/#{id}")
    #   store.transaction { store['']}
    # end

    def update_board(id, issues)
      store = board_store(id)
      store.transaction do
        store['issues'] = issues.map { |issue| issue.to_h }
        store['last_updated'] = Time.now
      end
    end

    def get_board(id)
      board = all.find{ |b| b.id == id }
      store = board_store(id)
      issues = store
        .transaction { store['issues'] || [] }
        .map{ |attrs| Issue.new(attrs) }
      RapidBoard.new({
        'id' => id,
        'name' => board.name,
        'query' => board.query,
        'issues' => issues
      })
    end

    def board_last_updated(id)
      store = board_store(id)
      store.transaction { store['last_updated'] }
    end

    def self.instance
      @@boards ||= Boards.new(Factory.instance)
    end

  private

    def boards_store
      @factory.find_or_create('boards')
    end

    def board_store(id)
      @factory.find_or_create("boards/#{id}")
    end
  end
end
