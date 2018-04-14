class QueryBuilder
  attr_reader :query

  def initialize(query)
    @query = clean(query)
  end

  def and(query)
    @query = "(#{@query}) AND (#{clean(query)})"
    self
  end

private

  def clean(query)
    if /ORDER BY/.match(query)
      /(.*)(\sORDER BY.*)/.match(query)[1]
    else
      query
    end
  end
end
