class DataTable
  attr_reader :headers
  attr_reader :rows

  def initialize(headers, rows)
    @headers = headers
    @rows = rows
  end

  def marshal_for_terminal
    upcase_headers + rows
  end

  def get_binding
    binding()
  end

private

  def upcase_headers
    headers.map do |row|
      row.map{ |h| h.upcase }
    end
  end

end