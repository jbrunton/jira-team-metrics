class DataTable
  attr_reader :headers
  attr_reader :rows

  def initialize(headers, rows)
    @headers = headers
    @rows = rows
  end

  def marshal_for_terminal
    marshal_headers_for_terminal + marshal_rows_for_terminal
  end

  def get_binding
    binding()
  end

private

  def marshal_headers_for_terminal
    headers.map do |row|
      row.map{ |item| marshal_item_for_terminal(item).upcase }
    end
  end

  def marshal_rows_for_terminal
    rows.map do |row|
      row.map{ |item| marshal_item_for_terminal(item) }
    end
  end

  def marshal_item_for_terminal(item)
    if item.kind_of?(Hash)
      item[:text]
    else
      item
    end
  end
end