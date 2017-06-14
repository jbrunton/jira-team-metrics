class DataTable
  attr_reader :rows

  def initialize(rows)
    @rows = rows
  end

  def marshal_for_terminal
    @rows.map{ |row| row.marshal_for_terminal }
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

    def marshal_for_terminal
      @items.map  do |item|
        s = item.to_s
        if s.length > 60
          # truncate long strings for terminal
          s[0,59] + '…'
        else
          # don't return the string representation for numbers as the type informs table formatting
          item
        end
      end
    end
  end

  class Header < Row
    def initialize(items)
      super(items, nil)
    end

    def marshal_for_terminal
      super.map { |item| item.upcase }
    end
  end

end