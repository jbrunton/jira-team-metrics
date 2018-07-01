class JiraTeamMetrics::QueryBuilder
  attr_reader :query

  def initialize(query)
    @query = clean(query)
  end

  def and(query)
    clean_query = clean(query)
    if @query.blank?
      @query = clean_query
    elsif !clean_query.blank?
      @query = "(#{@query}) AND (#{clean_query})"
    end
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
