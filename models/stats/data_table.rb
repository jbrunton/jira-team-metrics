class DataTable
  attr_reader :rows

  def initialize(rows)
    @rows = rows
  end

  def column(index)
    @rows
      .select{ |row| !row.is_a?(DataTable::Header) }
      .map{ |row| row.items[index] }
  end

  class Row
    attr_reader :items
    attr_reader :object

    def initialize(items, object)
      @items = items
      @object = object
    end
  end

  class Header < Row
    def initialize(items)
      super(items, nil)
    end
  end

end