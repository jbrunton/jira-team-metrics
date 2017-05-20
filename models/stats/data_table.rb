class DataTable
  attr_reader :rows

  def initialize(rows)
    @rows = rows
  end

  def marshal_for_terminal
    @rows.map{ |row| row.marshal_for_terminal }
  end

  class Row
    attr_reader :items
    attr_reader :object

    def initialize(items, object)
      @items = items
      @object = object
    end

    def marshal_for_terminal
      @items
    end
  end

  class Header < Row
    def initialize(items)
      super(items, nil)
    end

    def marshal_for_terminal
      @items.map { |item| item.upcase }
    end
  end

end