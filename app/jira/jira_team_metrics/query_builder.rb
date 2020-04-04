class JiraTeamMetrics::QueryBuilder
  attr_reader :query

  def initialize(query, language = :jql)
    @query = clean(query)
    @language = language
  end

  def and(query)
    clean_query = clean(query)
    if @query.blank?
      @query = clean_query
    elsif !clean_query.blank?
      op = case @language
        when :jql
          'AND'
        when :mql
          'and'
        else
          raise "Invalid language: #{@language}"
      end
      @query = "(#{@query}) #{op} (#{clean_query})"
    end
    self
  end

private

  def clean(query)
    if /ORDER BY/.match(query)
      # remove any ordering clauses, as we may wish to AND other clauses to the query (and order doesn't matter for
      # purposes of syncing)
      if query.upcase.start_with?('ORDER BY')
        ''
      else
        /(.*)(\sORDER BY.*)/.match(query)[1]
      end
    else
      query
    end
  end
end
