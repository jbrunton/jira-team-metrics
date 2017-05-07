require './store/factory'
require './models/jira/rapid_view'

module Store
  class Boards
    def initialize(factory)
      @factory = factory
    end

    def boards
      boards_store.transaction { boards_store['boards'] }
    end

    def last_updated
      boards_store.transaction { boards_store['last_updated'] }
    end

    def update(boards)
      boards_store.transaction do
        boards_store['boards'] = boards
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
        store['issues'] = issues
        store['last_updated'] = Time.now
      end
    end

    def get_board(id)
      board = boards[id]
      store = board_store(id)
      issues = store.transaction do
        store['issues']
      end
      Jira::RapidBoard.new({
        id: id,
        name: board['name'],
        query: board['query'],
        issues: issues
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
